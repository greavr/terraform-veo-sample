resource "google_service_account" "infra_sa" {
  account_id   = var.service_account_id
  display_name = "Infrastructure Management Service Account"
}

resource "google_folder_iam_member" "sa_project_creator" {
  folder = google_folder.new_folder.name
  role   = "roles/resourcemanager.projectCreator"
  member = google_service_account.infra_sa.member
}