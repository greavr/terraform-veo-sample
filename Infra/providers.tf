# ----------------------------------------------------------------------------------------------------------------------
# Configure Providers
# ----------------------------------------------------------------------------------------------------------------------
provider "google" {
    credentials = file("/home/admin/.config/gcloud/application_default_credentials.json")
}

provider "google-beta" {
    credentials = file("/home/admin/.config/gcloud/application_default_credentials.json")
}