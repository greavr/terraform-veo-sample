# ----------------------------------------------------------------------------------------------------------------------
# Cloud Function Script for Group Sync
# ----------------------------------------------------------------------------------------------------------------------
resource "google_cloudfunctions2_function" "my_function" {
  name     = "user-folder-creation"
  location = var.primary_region
  
  build_config {
    runtime     = "python311"
    entry_point = "scheduled_function_handler" # Must match function name in main.py
    source {
      storage_source {
        bucket = google_storage_bucket.source_bucket.name
        object = google_storage_bucket_object.source_object.name
      }
    }
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
      GROUP_MAPPING = var.GROUP_MAPPING
      DELEGATED_ADMIN_EMAIL  = var.DELEGATED_ADMIN_EMAIL
    }

  }

  depends_on = [
    google_storage_bucket_object.source_object,
    google_service_account.group-lister-sa
  ]
}
