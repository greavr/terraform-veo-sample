# ==============================================================================
# OUTPUTS
# ==============================================================================
output "folder_id" {
  description = "The ID of the newly created folder."
  value       = google_folder.new_folder.folder_id
}