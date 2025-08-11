# terraform-veo-sample
Sample Terraform to provision and secure multiple geo-diverse GCP projects running VEO

Requirement: 
- **GCP PROJECT INTO WHICH TO DEPLOY**
- **GCP BILLING ACCOUNT**

# Tool Setup Guide

[Tool Install Guide](tools/ReadMe.md)

# Environment Setup
* Install tools (Terraform / GCloud)


# Deploy guide
```
cd Infra
terraform init
terraform plan
terraform
```

# Required Permissions
```
roles/resourcemanager.folderCreator
roles/billing.user
roles/resourcemanager.projectCreator
```

# Google Group Processing

This project contains a Google Cloud Function that **runs on a 30-minute schedule**. It reads a predefined list of Google Groups from an environment variable and lists the full name and email of all members to the logs.

The primary output (the list of names) is **printed to the function's logs** in Cloud Logging.

## Setup and Deployment

The initial setup for enabling APIs, creating a service account, and configuring Domain-Wide Delegation is identical to the previous version. If you have already done that, you can skip to Step 4.

### Step 1-3: Initial Configuration

The following is handled by Terraform:
1.  **Enabling APIs** (Cloud Functions, Cloud Build, Admin SDK).
2.  **Creating a Service Account**.

This step is required manually
**Configuring Domain-Wide Delegation** 
1.  First, get the **Unique ID** (Client ID) of the service account. **Do not use the email address for this step.**
    ```bash
    gcloud iam service-accounts describe group-lister-sa@{your-project-id}.iam.gserviceaccount.com --project="{your-project-id}" --format='value(oauth2ClientId)'
    ```
    Copy the long number that is returned.
2.  Navigate to your **Google Admin Console**: [admin.google.com](http://admin.google.com)
3.  Go to **Security > Access and data control > API controls**.
4.  Under **Domain-wide Delegation**, click **Manage Domain-Wide Delegation**.
5.  Click **Add new**.
6.  Paste the **Unique ID** from step 1 into the **Client ID** field.
7.  In the **OAuth Scopes** field, paste the following scopes exactly as they are, separated by a comma:
    ```
    https://www.googleapis.com/auth/admin.directory.group.member.readonly,
    https://www.googleapis.com/auth/admin.directory.user.readonly
    ```
8.  Click **Authorize**.


### Step 4: Deploy the Scheduled Cloud Function

This deployment command is different. It uses the `--schedule` flag to create a Cloud Scheduler job that triggers the function automatically.

1.  **Prepare the `GROUP_MAPPING` variable**. The function expects a JSON string that represents a dictionary. The function will process the **keys** of this dictionary as the group emails. The values can be anything and are ignored by this script.

    *Example*: If you want to check the groups `engineering@your-domain.com` and `sales@your-domain.com`, you could create the following JSON structure.
    ```json
    {
      "engineering@your-domain.com": "value-a",
      "sales@your-domain.com": "value-b"
    }
    ```

2.  **Run the deploy command**. Place the JSON structure from the previous step inside single quotes (`'...'`). Replace all other placeholder values.

    * `your-function-name`: A name for your function (e.g., `scheduled-group-lister`).
    * `your-region`: A GCP region (e.g., `us-central1`).
    * `your-service-account-email`: The email of the service account from Step 2.
    * `admin-user@your-domain.com`: The email of a Google Workspace admin user.

    ```bash
    gcloud functions deploy your-function-name \
      --gen2 \
      --runtime=python312 \
      --region=your-region \
      --source=. \
      --entry-point=list_group_members_cron \
      --trigger-topic=cloud-function-scheduler \
      --schedule="every 30 minutes" \
      --service-account=your-service-account-email \
      --set-env-vars="DELEGATED_ADMIN_EMAIL=admin-user@your-domain.com,GROUP_MAPPING='{\"engineering@your-domain.com\":\"eng\",\"sales@your-domain.com\":\"sls\"}'"
    ```
    **Note**: The `--schedule` flag automatically creates the necessary Pub/Sub topic and Cloud Scheduler job for you.

## Triggering the Function

* **Automatic Trigger**: The function will now run automatically every 30 minutes.
* **Manual Trigger**: To test the function without waiting, you can trigger it manually.
    1.  In the Google Cloud Console, navigate to **Cloud Scheduler**.
    2.  Find the job created by the deployment (it will contain your function's name).
    3.  Click the **`⋮`** menu on the right and select **Force run**.


# Process
- Create the bootstrap project
  - This will contain the cloudbuild process, and the secrets for the billing account
  - This will setup the SA and folder which will contain the new projects and give the SA permission to do its tasks