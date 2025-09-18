# ----------------------------------------------------------------------------------------------------------------------
# Create GCS Bucket
# ----------------------------------------------------------------------------------------------------------------------
resource "google_storage_bucket" "bucket" {
    project                     = google_project.projects.project_id
    name                        = "${var.project_name}-veo"
    location                    = var.project_location
    force_destroy               = true 
    storage_class               = "STANDARD" 
    uniform_bucket_level_access = true
    
    versioning {
        enabled = false
    }

    depends_on = [google_project_service.enable-services]
}