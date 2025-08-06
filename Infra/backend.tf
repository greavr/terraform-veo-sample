terraform {
  backend "gcs" {
    # The bucket name will be provided by the -backend-config flag in cloudbuild.yaml
    # but the prefix is defined here.
    prefix = "terraform/state"
  }
}