# ----------------------------------------------------------------------------------------------------------------------
# Set Folder Permissions
# ----------------------------------------------------------------------------------------------------------------------
# Assign permssions
resource "google_folder_iam_member" "folder-admins" {
  folder = google_folder.new_folder.id

  for_each = {
    for pair in setproduct(var.default_admins, var.owner_permissions) : "${pair[0]}-${pair[1]}" => {
      member = pair[0]
      role   = pair[1]
    }
  }

  role   = each.value.role
  # Add the "user:" prefix to the email address
  member = "user:${each.value.member}"


  depends_on = [ google_folder.new_folder ]
}

# Asssign CF Permissions
resource "google_folder_iam_member" "cf_sa_roles" {
    folder = google_folder.new_folder.id
    
    for_each = toset(var.cf_sa_roles)
    role    = "roles/${each.value}"
    member  = "serviceAccount:${var.cf-sa}"


    depends_on = [ google_folder.new_folder ]
}

# Assign Global Access Permissions
# Use this sub-list to assing permissions
resource "google_folder_iam_member" "user-roles" {
   folder = google_folder.new_folder.id

  for_each = {
    # Use the filtered list of regional members with setproduct
    for pair in setproduct(var.var.global_access_group, var.var.global_access_group_permissions) : "${pair[0]}-${pair[1]}" => {
      member = pair[0]
      role   = pair[1]
    }
  }

  role    = each.value
  member  = "group:${each.value.member}"

  depends_on = [google_folder.new_folder]
}