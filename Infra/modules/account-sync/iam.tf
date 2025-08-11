
# ----------------------------------------------------------------------------------------------------------------------
# CREATE SERVICE ACCOUNT & Permissions
# ----------------------------------------------------------------------------------------------------------------------
# CF Group Listening
resource "google_service_account" "group-lister-sa" {
    project = var.gcp_project

    account_id   = "group-lister-sa"
    display_name = "group-lister-sa"
}

resource "google_project_iam_member" "service_account-roles" {
    project = var.gcp_project
    
    for_each = toset(var.cf_sa_roles)
    role    = "roles/${each.value}"
    member  = "serviceAccount:${google_service_account.group-lister-sa.email}"


    depends_on = [ google_service_account.group-lister-sa ]
}