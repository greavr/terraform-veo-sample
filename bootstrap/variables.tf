# ----------------------------------------------------------------------------------------------------------------------
# Variables
# ----------------------------------------------------------------------------------------------------------------------
# Parent Folder
variable "folder_display_name" {
    type = string
    description = "Parent Folder Name"
}

# Billing Account
variable "billing_account_id" {
    type = string
    description = "Billing Account to use with projects"
}

variable "org_id" {
  description = "The ID of the organization where resources will be created."
  type        = string
}

# Project Admins
variable "project_admins" {
    type = list(string)
    description = "List of Email addresses to make as admin"
}


# ----------------------------------------------------------------------------------------------------------------------
# Default Variables
# ----------------------------------------------------------------------------------------------------------------------
# Project Name
variable "project_name" {
    type = string
    description = "Name of the controlling project"
    default = "veo-tf-controller"
}



# Project Location
variable "project_location" {
    type = string
    description = "Admin project location"
    default = "us-west1"
}

# Terraform State Bucket Name
variable "tf_state_gcs_name" {
    type = string
    description = "Name for the GCS bucket to be created with TF State, will be appeneded to the project name"
    default = "-tf-state"
}

# TF SA Name
variable "terraform_sa_name" {
    type = string
    description = "Name for the Terraform SA"
    default = "veo-tf-deployer-sa"
}

# Folder Permissions
variable "terraform_sa_permission" {
    type = list(string)
    default = [
        "roles/editor",
        "roles/resourcemanager.projectCreator",
        "roles/secretmanager.secretAccessor"
    ]
}

# Project Permissions
variable "folder_owner_permissions" {
    type = list(string)
    default = [
        "roles/owner"
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
        "cloudbuild.googleapis.com",
        "secretmanager.googleapis.com",
        "run.googleapis.com"
    ]
}