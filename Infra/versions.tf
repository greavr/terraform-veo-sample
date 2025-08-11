terraform {
  required_version = ">= 1.12.1"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.46.0"
    }
    google-beta = {
      source = "hashicorp/google-beta"
      version = "~> 6.46.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.11.1"
    }
  }
}