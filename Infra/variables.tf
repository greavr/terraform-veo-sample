# ----------------------------------------------------------------------------------------------------------------------
# Variables
# ----------------------------------------------------------------------------------------------------------------------
# Billing Account
variable "billing_account_id" {
    type = string
    description = "Billing Account to use with projects"
}

# Billing alert email
variable "billing_alert_email" {
    type = map(string)
    description = "Key Pair of region:billing-email"
}

# Project Owners
variable "default_admins" {
    type = list(string)
    description = "List of Email addresses to make as admin"
}

# Org ID
variable "org_id" {
  description = "The ID of the organization where resources will be created."
  type        = string
}

# Host project ID
variable "host_project_id" {
    description = "Project used to configure billing alerts and run the cloud function script"
    type = string
}

# Google Admin Email Account
variable "DELEGATED_ADMIN_EMAIL"{
    description = "Project used to configure billing alerts and run the cloud function script"
    type = string
}

# Folder To Project Mappiong
variable "GROUP_MAPPING"{
    description = "Mapping of Google Group to Projects"
    type = map(string)
}

# Global Access Group
variable "global_access_group" {
    description = "Group which has access to every project"
    type = list(string)
    default = []
}
# ----------------------------------------------------------------------------------------------------------------------
# Default Variables
# ----------------------------------------------------------------------------------------------------------------------
# Parent Folder
variable "folder_display_name" {
    type = string
    description = "Name of the folder to host the projects"
    default = "Veo Land"
}

# List of projects & gcp region to create
variable "projects_to_build" { 
    type = list(object({
        region = string
        name = string
        })
    )
    default = [
        {
            region = "us-east4"
            name = "veo-colab-nyc"
        },
        {
            region = "southamerica-east1"
            name = "veo-colab-sao"
        },
        {
            region = "northamerica-northeast2"
            name = "veo-colab-tor"
        }
        ]
}

# Billing alert info
variable "billing_alert_level" {
    type = number
    description = "Numeric value of the billing alert level, default is 5000 ($5,000)"
    default = 15000
}


# Project Permissions
variable "user_project_permissions" {
    type = list(string)
    default = [
        "roles/aiplatform.user",
        "roles/aiplatform.admin",
        "roles/storage.objectCreator",
        "roles/storage.objectViewer",
        "roles/viewer"
    ]
}

# Project Permissions
variable "owner_project_permissions" {
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
        "storage-api.googleapis.com",
        "storage-component.googleapis.com",
        "cloudaicompanion.googleapis.com",
        "generativelanguage.googleapis.com",
        "aiplatform.googleapis.com",
        "geminicloudassist.googleapis.com",
        "billingbudgets.googleapis.com",
        "cloudbilling.googleapis.com",
        "dataform.googleapis.com"
    ]
}

# Default Group Sync
variable "sync_schedule" {
    type = string
    description = "Cron schedule, default is every 30 minutes every day"
    default = "* * * * *"
  
}