output "secret_version_id" {
  value = google_secret_manager_secret_version.db_password_version.id
}