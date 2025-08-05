# ----------------------------------------------------------------------------------------------------------------------
# Variables
# ----------------------------------------------------------------------------------------------------------------------
# Parent Folder
variable "parent_folder_name" {
    type = string
    description = "Parent Folder Name"
}

# Billing Account
variable "billing_account_id" {
    type = string
    description "Billing Account to use with projects"
}

variable "org_id" {
  description = "The ID of the organization where resources will be created."
  type        = string
}

# Folder Admins
variable "folder_admins" {
    type = list(string)
    description = "List of Email addresses to make as admin"
    default = ["rgreaves@google.com", "marianalucio@google.com"]
}

# Folder Permissions
variable "terraform_sa_permission" {
    type = list(string)
    default = [
        "roles/editor",
        "roles/resourcemanager.projectCreator"
    ]
}

# API to enable
variable "project_services" {
    type = list(string)
    default = [
        "compute.googleapis.com",
        "cloudresourcemanager.googleapis.com",
        "iam.googleapis.com",
        "logging.googleapis.com",
        "monitoring.googleapis.com",
        "opsconfigmonitoring.googleapis.com",
        "serviceusage.googleapis.com",
        "stackdriver.googleapis.com",
        "servicemanagement.googleapis.com",
        "servicecontrol.googleapis.com",
        "storage.googleapis.com",
        "cloudaicompanion.googleapis.com",
        "generativelanguage.googleapis.com",
        "aiplatform.googleapis.com",
        "geminicloudassist.googleapis.com",
        "cloudbuild.googleapis.com".
        "secretmanager.googleapis.com",
        "run.googleapis.com"
    ]
}