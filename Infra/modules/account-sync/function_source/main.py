import os
import json
import functions_framework
import logging
import sys # Added for stdout stream

# Import and setup Google Cloud Logging
from google.cloud.logging.handlers import StructuredLogHandler # Import the correct handler
from google.api_core.exceptions import NotFound
from google.cloud import storage
from google.auth.impersonated_credentials import ImpersonatedCredentials
from googleapiclient.discovery import build
from google.oauth2 import service_account
from googleapiclient.errors import HttpError

# --- LOGGING SETUP FOR CLOUD FUNCTIONS ---
logger = logging.getLogger()
handler = StructuredLogHandler(stream=sys.stdout)
logger.addHandler(handler)
logger.setLevel(logging.INFO)
# --- END LOGGING SETUP ---


# --- Environment Variables ---
# The email of a Google Workspace user with permissions to read group members.
# This user is impersonated by the service account.
DELEGATED_ADMIN_EMAIL = os.environ.get('DELEGATED_ADMIN_EMAIL')

# A JSON string mapping group emails to their corresponding Google Cloud Project IDs.
# Example: '{"gcp-users@example.com": "my-gcp-project-123", "data-scientists@example.com": "another-project-456"}'
GROUP_MAPPING_JSON = os.environ.get('GROUP_MAPPING')

logging.info(f"DELEGATED_ADMIN_EMAIL: {DELEGATED_ADMIN_EMAIL}")
logging.info(f"GROUP_MAPPING_JSON: {GROUP_MAPPING_JSON}")

# --- Constants ---
# OAuth 2.0 scopes required for Google APIs.
SCOPES = [
    'https://www.googleapis.com/auth/admin.directory.group.member.readonly',
    'https://www.googleapis.com/auth/admin.directory.user.readonly',
    'https://www.googleapis.com/auth/devstorage.full_control'
]
# Suffix for the GCS bucket name. The final name will be "[PROJECT_ID]-veo".
BUCKET_NAME_SUFFIX = "-veo"


def get_directory_service():
    """Builds an authenticated Google Admin SDK Directory service object."""
    CREDS_FILE = 'creds.json'

    # Check if a local credentials file exists
    if os.path.exists(CREDS_FILE):
        # Authenticate using the service account key file
        credentials = service_account.Credentials.from_service_account_file(
            CREDS_FILE,
            scopes=SCOPES
        )
        # Impersonate the delegated admin user
        delegated_credentials = credentials.with_subject(DELEGATED_ADMIN_EMAIL)
        
    else:
        # Fall back to default application credentials (e.g., in Cloud Functions)
        credentials, _ = google.auth.default(scopes=SCOPES)
        
        # Use impersonation if the default credentials support it
        if hasattr(credentials, 'with_subject'):
            delegated_credentials = credentials.with_subject(DELEGATED_ADMIN_EMAIL)
        else:
            # Handle cases where impersonation is not supported
            # e.g., using a user account
            delegated_credentials = credentials
            
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
            logging.info(f"Created folder: gs://{bucket_name}/{folder_path}")
        else:
            logging.info(f"Folder gs://{bucket_name}/{folder_path} already exists.")

        # 2. Set conditional IAM policy on the bucket for the user's folder.
        policy = bucket.get_iam_policy(requested_policy_version=3)
        
        # If the existing policy is version 1, we must upgrade it.
        if policy.version < 3:
            policy.version = 3

        role = "roles/storage.objectAdmin"
        member = f"user:{user_email}"
        condition_title = f"access_for_{user_email.replace('@', '_').replace('.', '_')}"
        condition_expression = f'resource.name.startsWith("projects/_/buckets/{bucket_name}/objects/{user_email}/")'

        # --- Robust Idempotency Check ---
        # Manually check if a binding with the same role, member, and condition already exists.
        is_policy_already_set = False
        for binding in policy.bindings:
            if (binding.get("role") == role and
                member in binding.get("members", set()) and
                binding.get("condition", {}).get("expression") == condition_expression):
                
                is_policy_already_set = True
                break
        
        if not is_policy_already_set:
            new_binding = {
                "role": role,
                "members": {member},
                "condition": {
                    "title": condition_title,
                    "description": "Grants user-specific access to their own folder.",
                    "expression": condition_expression
                }
            }
            policy.bindings.append(new_binding)
            bucket.set_iam_policy(policy)
            logging.info(f"Set IAM policy for {user_email} on bucket {bucket_name}.")
        else:
            logging.info(f"IAM policy for {user_email} on bucket {bucket_name} already exists.")

    except NotFound:
        # Use logging.warning for non-fatal, expected errors.
        logging.warning(f"Bucket '{bucket_name}' not found. Skipping folder creation for {user_email}.")
    except Exception as e:
        # Use logging.error for unexpected issues during a specific operation.
        logging.error(f"An unexpected error occurred during GCS operations for {user_email}: {e}")

# Triggered by a Pub/Sub message from Cloud Scheduler.
@functions_framework.cloud_event
def process_groups_and_create_folders(cloud_event):
    """
    Cloud Function to process Google Groups, create GCS folders for each member,
    and set user-specific permissions.
    """
    # 1. Validate configuration
    if not DELEGATED_ADMIN_EMAIL or not GROUP_MAPPING_JSON:
        # Use logging.critical for errors that prevent the function from running at all.
        logging.critical("FATAL ERROR: DELEGATED_ADMIN_EMAIL or GROUP_MAPPING environment variables are not set.")
        return 'Configuration missing.', 500

    try:
        group_mapping = json.loads(GROUP_MAPPING_JSON)
        if not isinstance(group_mapping, dict):
            raise TypeError("GROUP_MAPPING is not a valid JSON dictionary.")
    except (json.JSONDecodeError, TypeError) as e:
        logging.critical(f"FATAL ERROR: Could not parse GROUP_MAPPING environment variable. Error: {e}")
        return 'Invalid configuration.', 500

    logging.info(f"Cron job started. Processing {len(group_mapping)} group-to-project mappings.")

    try:
        directory_service = get_directory_service()

        # 2. Iterate through each group and its associated project
        for group_key, project_id in group_mapping.items():
            logging.info(f"--- Processing group: {group_key} for project: {project_id} ---")
            try:
                members = directory_service.members().list(groupKey=group_key).execute().get('members', [])
                if not members:
                    logging.info(f"No members found in group '{group_key}'.")
                    continue

                for member in members:
                    if member.get('type') == 'USER' and 'id' in member:
                        try:
                            user = directory_service.users().get(userKey=member['id']).execute()
                            email = user.get('primaryEmail')
                            if email:
                                full_name = user.get('name', {}).get('fullName', 'N/A')
                                logging.info(f"Found Member: {full_name} ({email})")
                                create_user_folder_and_set_permissions(project_id, email)
                        except HttpError as user_error:
                            logging.warning(f"Could not fetch details for member ID {member.get('id')}. Reason: {user_error}")

            except HttpError as group_error:
                logging.error(f"Error processing group '{group_key}': {group_error}")

        logging.info("--- Cron job finished successfully. ---")
        return 'OK', 200

    except Exception as e:
        # logging.exception automatically includes stack trace information.
        # It's the best choice inside an 'except' block for unexpected errors.
        logging.exception("An unexpected fatal error occurred in the main execution block.")
        return 'An internal server error occurred.', 500

if __name__ == "__main__":
    # In a local test, logs will go to the console by default.
    process_groups_and_create_folders(None);