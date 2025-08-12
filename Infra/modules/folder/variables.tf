# ----------------------------------------------------------------------------------------------------------------------
# Variables
# ----------------------------------------------------------------------------------------------------------------------
# Folder Name
variable "folder_display_name" {}
# Org ID
variable "org_id" {}

# CF SA Account
variable "cf-sa" {}

# Project Owners
variable "default_admins" {}
# Owner Permissions
variable "owner_permissions" {}

# CF SA Roles
variable "cf_sa_roles" {
    default = [
        "storage.objectAdmin"
    ]
}

# Global Access Group
variable "global_access_group" {}
variable "global_access_group_permissions" {}