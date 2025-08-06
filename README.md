# terraform-veo-sample
Sample Terraform to provision and secure multiple geo-diverse GCP projects running VEO

Requirement: 
- **GCP PROJECT INTO WHICH TO DEPLOY**
- **GCP BILLING ACCOUNT**

# Tool Setup Guide

[Tool Install Guide](tools/ReadMe.md)

# Environment Setup
* Install tools


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

# Process
- Create the bootstrap project
  - This will contain the cloudbuild process, and the secrets for the billing account
  - This will setup the SA and folder which will contain the new projects and give the SA permission to do its taks