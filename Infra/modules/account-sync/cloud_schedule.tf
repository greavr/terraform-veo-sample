# ----------------------------------------------------------------------------------------------------------------------
# Sync Schedule
# ----------------------------------------------------------------------------------------------------------------------
resource "google_cloud_scheduler_job" "job" {
  name     = "invoke-scheduled-function-job"
  schedule = var.default_schedule
  time_zone = "Etc/UTC"
  region = var.primary_region

  http_target {
    http_method = "POST"
    uri         = google_cloudfunctions2_function.my_function.service_config[0].uri

    # Use OIDC for secure, authenticated invocations
    oidc_token {
      service_account_email = google_cloudfunctions2_function.my_function.service_config[0].service_account_email
      # The 'audience' is automatically inferred from the 'uri' by the provider.
    }
  }

  depends_on = [
    google_cloudfunctions2_function.my_function
  ]
}
