# ----------------------------------------------------------------------------------------------------------------------
# Create a new folder for the projects
# ----------------------------------------------------------------------------------------------------------------------
resource "google_folder" "new_folder" {
  display_name = var.folder_display_name
  parent       = "organizations/${var.org_id}"
}