# ----------------------------------------------------------------------------------------------------------------------
# Create Terraform SA
# ----------------------------------------------------------------------------------------------------------------------
# SA
resource "google_service_account" "tf_sa" {
  project     = google_project.project.project_id

  account_id   = var.tf_deployer_sa_name
  display_name = "Terraform Deployer Service Account"

  depends_on = [ google_project.project ]
}

# Assign permssions
resource "google_folder_iam_member" "sa_project_creator" {
  folder = var.parent_folder
  for_each = toset(var.tf_deployer_sa_permissions)
  role   = each.value
  member = "serviceAccount:${google_service_account.tf_sa.email}"

  depends_on = [ google_service_account.tf_sa ]
}

# Grant Access to the billing account
resource "google_billing_account_iam_member" "billing_user_access" {
  billing_account_id = var.billing_account_id
  role               = "roles/billing.user"
  member = "serviceAccount:${google_service_account.tf_sa.email}"

  depends_on = [ google_service_account.tf_sa ]
}