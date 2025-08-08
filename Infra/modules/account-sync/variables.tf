# Variables

variable "gcp_project" {}
variable "default_schedule" {}

variable "service_to_enable" {
    default = [
        "run.googleapis.com",
        "cloudfunctions.googleapis.com",
        "cloudbuild.googleapis.com",
        "cloudscheduler.googleapis.com",
        "artifactregistry.googleapis.com"
    ]
}

variable "primary_region" {
  default = "us-west1"
}