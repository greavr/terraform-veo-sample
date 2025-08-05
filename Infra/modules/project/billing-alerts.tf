# ----------------------------------------------------------------------------------------------------------------------
# Variables
# ----------------------------------------------------------------------------------------------------------------------

resource "google_billing_budget" "budget" {
  billing_account = var.billing_account_id
  display_name    = "VEO Alert Budget"

  budget_filter {
    projects = ["projects/${google_project.projects.number}"]
  }

  amount {
    specified_amount {
      currency_code = "USD"
      units         = var.billing_alert_level
    }
  }

  threshold_rules {
    threshold_percent = 1.0
  }
  threshold_rules {
    threshold_percent = 1.0
    spend_basis       = "FORECASTED_SPEND"
  }

  all_updates_rule {
    monitoring_notification_channels = [
      google_monitoring_notification_channel.email_notification.id,
    ]
    disable_default_iam_recipients = true
  }

    depends_on = [ google_monitoring_notification_channel.email_notification ]
}
