# ----------------------------------------------------------------------------------------------------------------------
# Create Secrets
# ----------------------------------------------------------------------------------------------------------------------
# Create set for Billing ID
resource "google_secret_manager_secret" "billing_id_secret" {
    project = var.host_project_name
        
    # The user-friendly name for your secret
    secret_id = "billing-id"

    # Define the replication policy for the secret
    replication {
        automatic = true
    }
}

resource "google_secret_manager_secret_version" "billing_id_secret_version" {
  # Links this version to the secret container created above
  secret = google_secret_manager_secret.billing_id_secret.id

  # The actual sensitive data to be stored
  secret_data = var.billing_account_id
}