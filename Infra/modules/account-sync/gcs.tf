# ----------------------------------------------------------------------------------------------------------------------
# GCS Bucket for the code
# ----------------------------------------------------------------------------------------------------------------------
resource "google_storage_bucket" "source_bucket" {
  name                        = "${var.gcp_project}-cf-source-bucket2"
  location                    = var.primary_region
  uniform_bucket_level_access = true


  depends_on = [ google_project_service.enable-services ]
}