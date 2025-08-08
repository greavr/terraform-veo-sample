terraform {
  backend "gcs" {
    bucket  = "rgreaves-sandbox-dcc81-tfstate"
    prefix  = "terraform/state"
  }
}
