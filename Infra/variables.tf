# ----------------------------------------------------------------------------------------------------------------------
# Variables
# ----------------------------------------------------------------------------------------------------------------------
# Parent Folder
variable "parent_folder" {
    type = string
    description = "Folder underwhich to create all the projects"
}

# Billing Account
variable "billing_account_id" {
    type = string
    description = "Billing Account to use with projects"
}

# Billing alert email
variable "billing_alert_email" {
    type = string
    description = "Email to notify for spend alerts"
}

# Project Owners
variable "default_admins" {
    type = list(string)
    description = "List of Email addresses to make as admin"
}

# List of projects & gcp region to create
variable "projects_to_build" { 
    type = list(object({
        region = string
        name = string
        })
    )
    default = [{
            region = "europe-west2"
            name = "veo-colab-london"
        },
        {
            region = "us-west1"
            name = "veo-colab-oregon"
        },
        {
            region = "us-east1"
            name = "veo-colab-carolina"
        }]
}

# Billing alert info
variable "billing_alert_level" {
    type = number
    description = "Numeric value of the billing alert level, default is 5000 ($5,000)"
    default = 5000
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
        "cloudaicompanion.googleapis.com",
        "generativelanguage.googleapis.com",
        "aiplatform.googleapis.com",
        "geminicloudassist.googleapis.com",
        "billingbudgets.googleapis.com"
    ]
}