# ----------------------------------------------------------------------------------------------------------------------
# CREATE Secret Key Chain
# ----------------------------------------------------------------------------------------------------------------------

resource "google_secret_manager_secret" "key_secret" {
  secret_id = "cloud-run-sa-key" # Name of the secret in Secret Manager

  replication {
    auto {}
  }

  depends_on = [ google_service_account_key.my_key ]
}

resource "google_secret_manager_secret_version" "key_version" {
  secret = google_secret_manager_secret.key_secret.id

  # The 'private_key' output is base64-encoded.
  # We decode it so Secret Manager stores the raw JSON string.
  secret_data = base64decode(google_service_account_key.my_key.private_key)
}