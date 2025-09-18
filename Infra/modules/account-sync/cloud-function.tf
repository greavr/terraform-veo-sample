# ----------------------------------------------------------------------------------------------------------------------
# Cloud Function Script for Group Sync
# ----------------------------------------------------------------------------------------------------------------------
resource "google_cloudfunctions2_function" "my_function" {
  name     = "user-folder-creation"
  location = var.primary_region


  build_config {
    runtime     = "python311"
    entry_point = "process_groups_and_create_folders" # Must match function name in main.py
    source {
      storage_source {
        bucket = google_storage_bucket.source_bucket.name
        object = google_storage_bucket_object.source_object.name
      }
    }
  }

  event_trigger {
    trigger_region = var.primary_region
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = google_pubsub_topic.function_trigger_topic.id
    retry_policy   = "RETRY_POLICY_RETRY"
  }

  service_config {
    max_instance_count = 1
    min_instance_count = 0 
    timeout_seconds    = 60
    # Allow all traffic, as we will rely on OIDC for secure auth from the scheduler
    ingress_settings   = "ALLOW_ALL"

    # Assign Custom Service Account
    service_account_email = google_service_account.group-reader-sa.email

    # Add environment variables
    environment_variables = {
      GROUP_MAPPING = jsonencode(var.GROUP_MAPPING)
      DELEGATED_ADMIN_EMAIL  = var.DELEGATED_ADMIN_EMAIL
      CREDS_FILE_PATH = "/etc/gcp-keys/creds.json"
    }

        # This block mounts the secret as a file
    secret_volumes {
      project_id = var.gcp_project
      mount_path = "/etc/gcp-keys" # The directory in the container
      
      # The ID of the secret in Secret Manager
      secret = google_secret_manager_secret.key_secret.secret_id

      versions {
        version = "latest"        # Use the "latest" version
        path    = "creds.json"    # Mount it as a file named "creds.json"
      }
    }

  }

  depends_on = [
    google_storage_bucket_object.source_object,
    google_service_account.group-reader-sa,
    google_pubsub_topic.function_trigger_topic,
    google_secret_manager_secret_version.key_version
  ]
}
