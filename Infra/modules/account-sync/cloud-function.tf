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
  }

  depends_on = [
    google_storage_bucket_object.source_object
  ]
}
