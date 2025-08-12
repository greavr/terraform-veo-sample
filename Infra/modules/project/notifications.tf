# ----------------------------------------------------------------------------------------------------------------------
# Configure Billing Alerts
# ----------------------------------------------------------------------------------------------------------------------
resource "google_monitoring_notification_channel" "email_notification" {
  project                     = google_project.projects.project_id
  display_name                = "Email Notification Channel for ${var.project_location}"
  type                        = "email"

  labels = {
    email_address = var.billing_alert_email[var.project_location]
  }

  depends_on = [ google_project.projects ]
}