# Variables
variable "gcp_project" {}
variable "default_schedule" {}

# Cloud Function Variables
variable "DELEGATED_ADMIN_EMAIL" {}
variable "GROUP_MAPPING" {}

# Default values
variable "service_to_enable" {
    default = [
        "run.googleapis.com",
        "cloudfunctions.googleapis.com",
        "cloudbuild.googleapis.com",
        "cloudscheduler.googleapis.com",
        "artifactregistry.googleapis.com",
        "pubsub.googleapis.com"
    ]
}

variable "primary_region" {
  default = "us-west1"
}

variable "cf_sa_roles" {
  default = [
    "storage.objectAdmin"
  ]
}