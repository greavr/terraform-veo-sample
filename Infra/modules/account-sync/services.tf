# ----------------------------------------------------------------------------------------------------------------------
# Enable APIs
# ----------------------------------------------------------------------------------------------------------------------
resource "google_project_service" "enable-services" {
    for_each = toset(var.service_to_enable)

    project = var.gcp_project
    service = each.value
    disable_on_destroy = false
}

resource "time_sleep" "wait_30_seconds" {
  create_duration = "30s"

  depends_on = [ google_project_service.enable-services ]
}