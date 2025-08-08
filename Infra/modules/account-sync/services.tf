# ----------------------------------------------------------------------------------------------------------------------
# Enable APIs
# ----------------------------------------------------------------------------------------------------------------------
resource "google_project_service" "enable-services" {
    for_each = toset(var.service_to_enable)

    project = var.gcp_project
    service = each.value
    disable_on_destroy = false
}