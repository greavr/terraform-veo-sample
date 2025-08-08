# ----------------------------------------------------------------------------------------------------------------------
# Configure Providers
# ----------------------------------------------------------------------------------------------------------------------
provider "google" {
    project               = var.host_project_id
    billing_project       = var.host_project_id
    user_project_override = true
}

provider "google-beta" {
    project               = var.host_project_id
    billing_project       = var.host_project_id
    user_project_override = true
}