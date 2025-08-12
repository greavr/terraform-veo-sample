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
    service_account_email = google_service_account.group-lister-sa.email

    # Add environment variables
    environment_variables = {
      GROUP_MAPPING = jsonencode(var.GROUP_MAPPING)
      DELEGATED_ADMIN_EMAIL  = var.DELEGATED_ADMIN_EMAIL
    }

  }

  depends_on = [
    google_storage_bucket_object.source_object,
    google_service_account.group-lister-sa,
    google_pubsub_topic.function_trigger_topic
  ]
}
