# ----------------------------------------------------------------------------------------------------------------------
# Pub Sub Trigger
# ----------------------------------------------------------------------------------------------------------------------
resource "google_pubsub_topic" "function_trigger_topic" {
  name    = "user-folder-creation-cron-topic"
  project = var.gcp_project

  depends_on = [ time_sleep.wait_30_seconds ]
}