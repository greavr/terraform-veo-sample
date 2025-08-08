# ----------------------------------------------------------------------------------------------------------------------
# Grant IAM Roles
# ----------------------------------------------------------------------------------------------------------------------

# Create local sub-list of users
locals {
  regional_user_members = distinct([
    for user in var.project_groups : "group:${user.email}" if user.region == var.project_location
  ])
}

# Use this sub-list to assing permissions
resource "google_project_iam_member" "user-roles" {
  project = google_project.projects.project_id

  for_each = {
    # Use the filtered list of regional members with setproduct
    for pair in setproduct(local.regional_user_members, var.user_permissions) : "${pair[0]}-${pair[1]}" => {
      member = pair[0]
      role   = pair[1]
    }
  }

  role    = each.value.role
  member  = each.value.member

  depends_on = [google_project.projects]
}

# Set the project owner permissions 
resource "google_project_iam_member" "owner-roles" {
  project = google_project.projects.project_id

  for_each = {
    for pair in setproduct(var.default_admins, var.owner_permissions) : "${pair[0]}-${pair[1]}" => {
      member = pair[0]
      role   = pair[1]
    }
  }

  role   = each.value.role
  # Add the "group:" prefix to the email address
  member = "group:${each.value.member}"

  depends_on = [google_project.projects]
}