output "service_account_email" {
  description = "The email of the newly created infrastructure service account."
  value       = google_service_account.infra_sa.email
}

output "project_id" {
  description = "The ID of the newly created project."
  value       = google_project.new_project.project_id
}