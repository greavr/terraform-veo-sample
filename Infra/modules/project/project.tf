# ----------------------------------------------------------------------------------------------------------------------
# Create Project
# ----------------------------------------------------------------------------------------------------------------------
# A random suffix to ensure project IDs are globally unique
resource "random_id" "suffix" {
  byte_length = 4
}

resource "google_project" "projects" {
  name            = var.project_name
  project_id      = "${var.project_name}-${random_id.suffix.hex}"
  folder_id       = var.parent_folder
  billing_account = var.billing_account_id

  labels = {
    terraform = "true"
    env       = "veo"
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# Enable APIs
# ----------------------------------------------------------------------------------------------------------------------
resource "google_project_service" "enable-services" {
    for_each = toset(var.services_to_enable)

    project = google_project.projects.id
    service = each.value
    disable_on_destroy = false

    depends_on = [ google_project.projects ]
}