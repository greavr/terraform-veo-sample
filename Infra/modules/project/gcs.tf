# ----------------------------------------------------------------------------------------------------------------------
# Create GCS Bucket
# ----------------------------------------------------------------------------------------------------------------------
resource "google_storage_bucket" "bucket" {
    project                     = google_project.projects.project_id
    name                        = "${var.project_name}-veo"
    location                    = var.project_location
    force_destroy               = true 
    storage_class               = "STANDARD" 
    uniform_bucket_level_access = false      

    versioning {
        enabled = false
    }

    depends_on = [google_project_service.enable-services]
}

# ----------------------------------------------------------------------------------------------------------------------
# Create Folder Per User
# ----------------------------------------------------------------------------------------------------------------------
resource "google_storage_bucket_object" "user_folders" {
    bucket  = google_storage_bucket.bucket.name

    for_each = {
      for user in var.project_users : "${user.email}-${user.region}" => user if user.region == var.project_location
    }

    name    = "${split("@", each.value.email)[0]}/" # Creates a folder for each user, e.g., "rgreaves@google.com becomes rgreaves/"
    content = " "            # The content can be empty for a folder placeholder   

    depends_on = [google_storage_bucket.bucket]          
}


# ----------------------------------------------------------------------------------------------------------------------
# Set permissions for each user on their folder
# ----------------------------------------------------------------------------------------------------------------------
resource "google_storage_object_acl" "user_folder_acl" {
    for_each = {
      for user in var.project_users : "${user.email}-${user.region}" => user if user.region == var.project_location
    }

  bucket = google_storage_bucket.bucket.name
  object = google_storage_bucket_object.user_folders[each.key].name
  role_entity = [
    "OWNER:user-${each.value.email}" # Grants the user ownership of their folder
  ]

  depends_on = [ google_storage_bucket_object.user_folders ]
}