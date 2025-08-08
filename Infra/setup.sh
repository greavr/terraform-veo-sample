#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# 1. Get the current GCP Project ID
PROJECT_ID=$(gcloud config get-value project)

# Check if the project ID was retrieved
if [ -z "$PROJECT_ID" ]; then
    echo "GCP Project ID not found. Make sure you have authenticated with gcloud and set a project."
    echo "You can set it using: gcloud config set project YOUR_PROJECT_ID"
    exit 1
fi

echo "Current GCP Project ID: $PROJECT_ID"

# 2. Define the bucket name
BUCKET_NAME="${PROJECT_ID}-tfstate"
LOCATION="US" # You can change this to your preferred location, e.g., "US-CENTRAL1"

echo "Terraform state bucket to be created: gs://$BUCKET_NAME"

# 3. Create the GCS bucket if it doesn't exist
if gsutil ls -b "gs://$BUCKET_NAME" >/dev/null 2>&1; then
    echo "Bucket gs://$BUCKET_NAME already exists."
else
    echo "Creating GCS bucket: gs://$BUCKET_NAME..."
    # Use -b for uniform bucket-level access (recommended)
    gsutil mb -p "$PROJECT_ID" -l "$LOCATION" -b on "gs://$BUCKET_NAME"

    # Enable versioning to keep history of your state files
    gsutil versioning set on "gs://$BUCKET_NAME"
    echo "Bucket created and versioning enabled."
fi


# 4. Create the backend.tf file
echo "Creating backend.tf file..."
cat > backend.tf << EOL
terraform {
  backend "gcs" {
    bucket  = "$BUCKET_NAME"
    prefix  = "terraform/state"
  }
}
EOL

echo "backend.tf created successfully:"
echo "---------------------------------"
cat backend.tf
echo "---------------------------------"
echo "Script finished successfully!"