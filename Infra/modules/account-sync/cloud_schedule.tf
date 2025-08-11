# ----------------------------------------------------------------------------------------------------------------------
# Sync Schedule
# ----------------------------------------------------------------------------------------------------------------------
resource "google_cloud_scheduler_job" "job" {
  name     = "invoke-scheduled-function-job"
  schedule = var.default_schedule
  time_zone = "Etc/UTC"
  region = var.primary_region

  pubsub_target {
    # Points to the Pub/Sub topic created above
    topic_name = google_pubsub_topic.function_trigger_topic.id
    # The message body sent to the function (can be anything)
    data = base64encode("trigger")
  }

  depends_on = [
    google_pubsub_topic.function_trigger_topic
  ]
}
