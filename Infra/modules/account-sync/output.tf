# ==============================================================================
# OUTPUTS
# ==============================================================================
output "cf-sa" {
  description = "Email of the service account"
  value       = google_service_account.group-lister-sa.email
}