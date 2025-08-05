resource "google_project" "new_project" {
  provider = google.impersonated

  name            = var.project_id
  project_id      = var.project_id
  folder_id       = google_folder.new_folder.folder_id
  billing_account = var.billing_account_id
}