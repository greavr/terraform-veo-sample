# ----------------------------------------------------------------------------------------------------------------------
# Configure Providers
# ----------------------------------------------------------------------------------------------------------------------
provider "google" {
}

provider "google-beta" {
}

# ----------------------------------------------------------------------------------------------------------------------
# Create Project(s)
# ----------------------------------------------------------------------------------------------------------------------
module "create_folder" {
    source  = "./modules/folder"
    
    # Standard settings
    folder_display_name = var.folder_display_name

    # Permissions
    default_admins = var.project_admins
    owner_permissions = var.folder_owner_permissions

    org_id = var.org_id

}

# ----------------------------------------------------------------------------------------------------------------------
# Create Project
# ----------------------------------------------------------------------------------------------------------------------
module "create_project" {
    source  = "./modules/project"

    # Standard settings
    parent_folder = module.create_folder.folder_id
    billing_account_id = var.billing_account_id
    services_to_enable = var.project_services
    tf_state_bucket_name = var.tf_state_gcs_name
   
    # SA Info
    tf_deployer_sa_name = var.terraform_sa_name
    tf_deployer_sa_permissions = var.terraform_sa_permission

    project_name  = var.project_name
    project_location = var.project_location

    depends_on = [ module.create_folder ]

}