# GCP Project Provisioner with Group Sync

This repository contains a Terraform-based solution to provision and secure multiple geo-diverse GCP projects.

It includes a **Group Sync Cloud Function** that runs on a 30-minute schedule. The function reads a list of Google Groups, fetches the members of each group, and creates a user-specific folder in a Google Cloud Storage bucket. It then sets IAM permissions so that only that user has access to their folder.

---

## Prerequisites

Before you begin, you will need:

1.  An existing **GCP Project** to host the Terraform state, the Cloud Function, and other core resources. This is referred to as the "bootstrap project".
2.  A **GCP Billing Account ID** to associate with the newly created projects.
3.  A **Google Workspace account** with administrator privileges to configure Domain-wide Delegation.
4.  The necessary command-line tools installed. You can find instructions in the [Tool Install Guide](tools/ReadMe.md).

---

## Setup and Deployment Guide

Follow these steps to configure and deploy the infrastructure.

### Step 1: Configure Your Deployment

All configuration is managed through a single variables file.

1.  Navigate to the `Infra` directory:
    ```bash
    cd Infra
    ```
2.  Create a `terraform.tfvars` file by copying the sample:
    ```bash
    cp terraform.tfvars.sample terraform.tfvars
    ```
3.  Open `terraform.tfvars` in a text editor and fill in the required values. This file includes the ID for your bootstrap project, billing account, and the configuration for the Group Sync function.

    **Example `terraform.tfvars`:**
    ```hcl
    # GCP Project to host Terraform state and the Cloud Function
    bootstrap_project_id      = "your-gcp-bootstrap-project-id"

    # GCP Billing Account ID for new projects
    billing_account_id        = "012345-6789AB-151544"

    # Email of a Google Workspace admin for domain delegation
    delegated_admin_email     = "admin@your-domain.com"

    # JSON map of Google Groups to process
    # Key: Group Email, Value: A short identifier (e.g., for folder prefixes)
    group_mapping = jsonencode({
      "gcp-users-del@your-domain.com" = "veo-colab-del",
      "gcp-users-pbx@your-domain.com"  = "veo-colab-pbx"
    })
    ```

### Step 2: Authenticate and Set Project Context

Run the provided setup script. This script will log you into `gcloud` and configure **Application Default Credentials (ADC)** to use your bootstrap project. Terraform uses these credentials to authenticate with Google Cloud.

```bash
./setup.sh
```
The script will prompt you to enter your **bootstrap project ID**. Make sure this matches the `bootstrap_project_id` you set in your `.tfvars` file.

### Step 3: Deploy with Terraform

Now you can initialize Terraform and deploy the resources.

1.  **Initialize Terraform**: Downloads the necessary providers.
    ```bash
    terraform init
    ```
2.  **Plan Deployment**: Review the changes that Terraform will make.
    ```bash
    terraform plan
    ```
3.  **Apply Changes**: Create the GCP resources. This will provision the service account, GCS bucket, and deploy the Cloud Function.
    ```bash
    terraform apply
    ```

### Step 4: Configure Domain-Wide Delegation (Manual Step)

Terraform creates the service account, but you must **manually grant it permission** to read group memberships from your Google Workspace account.

1.  **Get the Service Account's Unique ID**: After running `terraform apply`, Terraform will output the service account's Client ID. You can also retrieve it with this command:
    ```bash
    gcloud iam service-accounts describe terraform-managed-sa@${BOOTSTRAP_PROJECT_ID}.iam.gserviceaccount.com --project="${BOOTSTRAP_PROJECT_ID}" --format='value(oauth2ClientId)'
    ```
    *Replace `${BOOTSTRAP_PROJECT_ID}` with your actual bootstrap project ID.* Copy the long number that is returned.

2.  **Navigate to your Google Admin Console**: [admin.google.com](http://admin.google.com)

3.  Go to **Security > Access and data control > API controls**.

4.  Under **Domain-wide Delegation**, click **Manage Domain-Wide Delegation**.

5.  Click **Add new** and paste the **Unique ID** from step 1 into the **Client ID** field.

6.  In the **OAuth Scopes** field, paste the following scopes (separated by a comma):
    ```
    https://www.googleapis.com/auth/admin.directory.group.member.readonly,https://www.googleapis.com/auth/cloud-platform
    ```
7.  Click **Authorize**. The function will now be able to execute successfully on its schedule.

---

## How It Works

* **Terraform**: Provisions all necessary GCP resources, including a Service Account, a GCS bucket, and the Cloud Function.
* **Cloud Scheduler**: Triggers the Cloud Function every 30 minutes via a Pub/Sub topic.
* **Cloud Function**:
    * Reads the `GROUP_MAPPING` and `DELEGATED_ADMIN_EMAIL` environment variables set by Terraform.
    * Impersonates the delegated admin to interact with the Google Admin SDK.
    * For each group, it lists the members.
    * For each member, it creates a folder named after the user's email in a GCS bucket.
    * It applies an IAM policy to the folder, granting `roles/storage.objectAdmin` exclusively to that user.

---

## Cleanup

To remove all deployed resources and avoid ongoing charges, run the following command from the `Infra` directory:

```bash
terraform destroy
```

### Update Terraform
```bash
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
sudo echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get install terraform
terraform -install-autocomplete
```