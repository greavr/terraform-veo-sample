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


# Required Permissions
```
roles/resourcemanager.folderCreator
roles/billing.user
roles/resourcemanager.projectCreator