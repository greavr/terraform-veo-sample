import os
import json
import functions_framework
from google.api_core.exceptions import NotFound
from google.cloud import storage
from googleapiclient.discovery import build
import google.auth
from googleapiclient.errors import HttpError

# --- Environment Variables ---
# The email of a Google Workspace user with permissions to read group members.
# This user is impersonated by the service account.
DELEGATED_ADMIN_EMAIL = os.environ.get('DELEGATED_ADMIN_EMAIL')

# A JSON string mapping group emails to their corresponding Google Cloud Project IDs.
# Example: '{"gcp-users@example.com": "my-gcp-project-123", "data-scientists@example.com": "another-project-456"}'
GROUP_MAPPING_JSON = os.environ.get('GROUP_MAPPING')

# --- Constants ---
# OAuth 2.0 scopes required for Google APIs.
SCOPES = [
    'https://www.googleapis.com/auth/admin.directory.group.member.readonly',
    'https://www.googleapis.com/auth/admin.directory.user.readonly',
    'https://www.googleapis.com/auth/devstorage.full_control'
]
# Suffix for the GCS bucket name. The final name will be "[PROJECT_ID]-user-folders".
BUCKET_NAME_SUFFIX = "-user-folders"


def get_directory_service():
    """Builds an authenticated Google Admin SDK Directory service object."""
    credentials, _ = google.auth.default(scopes=SCOPES)
    delegated_credentials = credentials.with_subject(DELEGATED_ADMIN_EMAIL)
    return build('admin', 'directory_v1', credentials=delegated_credentials, cache_discovery=False)

def create_user_folder_and_set_permissions(project_id, user_email):
    """
    Creates a GCS folder for a user and sets user-specific IAM permissions.

    Args:
        project_id (str): The Google Cloud project ID where the bucket resides.
        user_email (str): The email of the user to grant permissions to.
    """
    try:
        storage_client = storage.Client()
        bucket_name = f"{project_id}{BUCKET_NAME_SUFFIX}"

        bucket = storage_client.get_bucket(bucket_name)

        # 1. Create folder (a zero-byte object with a trailing slash) if it doesn't exist.
        folder_path = f"{user_email}/"
        blob = bucket.blob(folder_path)
        if not blob.exists():
            blob.upload_from_string('', content_type='application/x-directory')
            print(f"  Created folder: gs://{bucket_name}/{folder_path}")
        else:
            print(f"  - Folder gs://{bucket_name}/{folder_path} already exists.")

        # 2. Set conditional IAM policy on the bucket for the user's folder.
        policy = bucket.get_iam_policy(requested_policy_version=3)
        role = "roles/storage.objectAdmin"
        member = f"user:{user_email}"

        # This binding grants the user access ONLY to objects prefixed with their folder path.
        new_binding = {
            "role": role,
            "members": {member},
            "condition": {
                "title": f"access_for_{user_email.replace('@', '_').replace('.', '_')}",
                "description": f"Grants access to objects prefixed with the user's email",
                "expression": f'resource.name.startsWith("projects/_/buckets/{bucket_name}/objects/{user_email}/")'
            }
        }
        
        # Avoid adding duplicate bindings.
        if new_binding not in policy.bindings:
            policy.bindings.append(new_binding)
            bucket.set_iam_policy(policy)
            print(f"  Set IAM policy for {user_email} on bucket {bucket_name}.")
        else:
            print(f"  - IAM policy for {user_email} on bucket {bucket_name} already exists.")

    except NotFound:
        print(f" ERROR: Bucket '{bucket_name}' not found. Skipping folder creation for {user_email}.")
    except Exception as e:
        print(f" ERROR: An unexpected error occurred during GCS operations for {user_email}: {e}")

# Triggered by a Pub/Sub message from Cloud Scheduler.
@functions_framework.cloud_event
def process_groups_and_create_folders(cloud_event):
    """
    Cloud Function to process Google Groups, create GCS folders for each member,
    and set user-specific permissions.
    """
    # 1. Validate configuration
    if not DELEGATED_ADMIN_EMAIL or not GROUP_MAPPING_JSON:
        print("FATAL ERROR: DELEGATED_ADMIN_EMAIL or GROUP_MAPPING environment variables are not set.")
        return 'Configuration missing.', 500

    try:
        group_mapping = json.loads(GROUP_MAPPING_JSON)
        if not isinstance(group_mapping, dict):
            raise TypeError("GROUP_MAPPING is not a valid JSON dictionary.")
    except (json.JSONDecodeError, TypeError) as e:
        print(f"FATAL ERROR: Could not parse GROUP_MAPPING environment variable. Error: {e}")
        return 'Invalid configuration.', 500

    print(f" Cron job started. Processing {len(group_mapping)} group-to-project mappings.")

    try:
        directory_service = get_directory_service()

        # 2. Iterate through each group and its associated project
        for group_key, project_id in group_mapping.items():
            print(f"\n--- Processing group: {group_key} for project: {project_id} ---")
            try:
                members = directory_service.members().list(groupKey=group_key).execute().get('members', [])
                if not members:
                    print(f"No members found in group '{group_key}'.")
                    continue

                for member in members:
                    if member.get('type') == 'USER' and 'id' in member:
                        try:
                            user = directory_service.users().get(userKey=member['id']).execute()
                            email = user.get('primaryEmail')
                            if email:
                                full_name = user.get('name', {}).get('fullName', 'N/A')
                                print(f"  - Found Member: {full_name} ({email})")
                                create_user_folder_and_set_permissions(project_id, email)
                        except HttpError as user_error:
                            print(f"  - Could not fetch details for member ID {member.get('id')}. Reason: {user_error}")

            except HttpError as group_error:
                print(f" ERROR processing group '{group_key}': {group_error}")

        print("\n--- Cron job finished successfully. ---")
        return 'OK', 200

    except Exception as e:
        print(f"An unexpected fatal error occurred: {e}")
        return 'An internal server error occurred.', 500