# ----------------------------------------------------------------------------------------------------------------------
# Create Project(s)
# ----------------------------------------------------------------------------------------------------------------------
module "create_project" {
    source  = "./modules/project"

    for_each = {for a_project in var.projects_to_build: a_project.name => a_project}

    # Standard settings
    parent_folder = var.parent_folder
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

    project_users = var.user_list  

}
