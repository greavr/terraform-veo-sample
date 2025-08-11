# ----------------------------------------------------------------------------------------------------------------------
# Create Cloud Function
# ----------------------------------------------------------------------------------------------------------------------
module "create_sync" {
    source  = "./modules/account-sync"

    gcp_project = var.host_project_id
    default_schedule = var.sync_schedule

    DELEGATED_ADMIN_EMAIL = var.DELEGATED_ADMIN_EMAIL
    GROUP_MAPPING = var.GROUP_MAPPING
    
    
}

# ----------------------------------------------------------------------------------------------------------------------
# Create Folder
# ----------------------------------------------------------------------------------------------------------------------
module "create_folder" {
    source  = "./modules/folder"
    
    # Standard settings
    folder_display_name = var.folder_display_name

    # Permissions
    default_admins = var.default_admins
    owner_permissions = var.owner_project_permissions

    org_id = var.org_id

    cf-sa = module.create_sync.cf-sa

    depends_on = [ module.create_sync ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Create Project(s)
# ----------------------------------------------------------------------------------------------------------------------
module "create_project" {
    source  = "./modules/project"

    for_each = {for a_project in var.projects_to_build: a_project.name => a_project}

    # Standard settings
    parent_folder = module.create_folder.folder_id
    billing_account_id = var.billing_account_id
    default_admins = var.default_admins
    services_to_enable = var.project_services

    #Billing Alert Info
    billing_alert_level = var.billing_alert_level
    billing_alert_email = var.billing_alert_email

    # Permissions
    owner_permissions = var.owner_project_permissions
    user_permissions = var.user_project_permissions

    project_name  = each.value.name
    project_location = each.value.region

    project_groups = var.group_list  

    depends_on = [ module.create_folder ]
}


