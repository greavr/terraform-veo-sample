import os
import json
import functions_framework
from google.oauth2 import service_account
from googleapiclient.discovery import build
import google.auth
from googleapiclient.errors import HttpError

# The email of a Google Workspace user with permissions to read group members.
# This user is impersonated by the service account.
DELEGATED_ADMIN_EMAIL = os.environ.get('DELEGATED_ADMIN_EMAIL')

# A JSON string representing a dictionary of groups to process.
# The function will process the keys of this dictionary as group emails.
# Example: '{"group1@example.com": "value1", "group2@example.com": "value2"}'
GROUP_MAPPING_JSON = os.environ.get('GROUP_MAPPING')

# OAuth 2.0 scopes required for the Google Admin SDK.
SCOPES = [
    'https://www.googleapis.com/auth/admin.directory.group.member.readonly',
    'https://www.googleapis.com/auth/admin.directory.user.readonly'
]

def get_directory_service():
    """Builds an authenticated Google Admin SDK Directory service object."""
    credentials, _ = google.auth.default(scopes=SCOPES)
    delegated_credentials = credentials.with_subject(DELEGATED_ADMIN_EMAIL)
    service = build('admin', 'directory_v1', credentials=delegated_credentials, cache_discovery=False)
    return service

# Triggered by a Pub/Sub message from Cloud Scheduler.
@functions_framework.cloud_event
def list_group_members_cron(cloud_event):
    """
    A Cloud Function triggered by Cloud Scheduler.

    It reads a dictionary of Google Groups from the GROUP_MAPPING environment
    variable and prints each member's full name and email to the logs.
    """
    # 1. Validate the function's configuration
    if not DELEGATED_ADMIN_EMAIL or not GROUP_MAPPING_JSON:
        print("FATAL ERROR: DELEGATED_ADMIN_EMAIL or GROUP_MAPPING environment variables are not set.")
        # Return a non-200 status to indicate failure to Cloud Scheduler
        return 'Configuration missing.', 500

    try:
        group_mapping = json.loads(GROUP_MAPPING_JSON)
        if not isinstance(group_mapping, dict):
            raise TypeError("GROUP_MAPPING is not a valid JSON dictionary.")
    except (json.JSONDecodeError, TypeError) as e:
        print(f"FATAL ERROR: Could not parse GROUP_MAPPING environment variable. Error: {e}")
        return 'Invalid configuration.', 500

    # 2. Get the list of groups from the keys of the dictionary
    group_keys = list(group_mapping.keys())
    print(f"Cron job started. Processing {len(group_keys)} groups from environment variable.")
    print(f"Groups to process: {group_keys}")

    try:
        service = get_directory_service()

        # 3. Iterate through each group and list its members
        for group_key in group_keys:
            try:
                print(f"\n--- Fetching members for group: {group_key} ---")
                members_result = service.members().list(groupKey=group_key).execute()
                members = members_result.get('members', [])

                if not members:
                    print(f"No members found in group '{group_key}' or group does not exist.")
                    continue

                for member in members:
                    if member.get('type') == 'USER' and 'id' in member:
                        try:
                            # Get user details to retrieve the full name
                            user = service.users().get(userKey=member['id']).execute()
                            full_name = user.get('name', {}).get('fullName', 'N/A')
                            email = user.get('primaryEmail', 'N/A')
                            print(f"  - Found Member: {full_name} ({email})")
                        except HttpError as user_error:
                            print(f"  - Could not fetch details for member ID {member.get('id')}. Reason: {user_error}")

            except HttpError as group_error:
                print(f"ERROR processing group '{group_key}': {group_error}")

        print("\n--- ✅ Cron job finished successfully. ---")
        return 'OK', 200

    except Exception as e:
        print(f"An unexpected fatal error occurred: {e}")
        return 'An internal server error occurred.', 500