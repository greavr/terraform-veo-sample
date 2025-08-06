# ----------------------------------------------------------------------------------------------------------------------
# Variables
# ----------------------------------------------------------------------------------------------------------------------
# Parent Folder
variable "parent_folder" {}
# Project List
variable "project_name" {}
# Project Location
variable "project_location" {}
# Billing Account
variable "billing_account_id" {}
# TF State Bucket Name
variable "tf_state_bucket_name" {}



# Terraform Deployer SA
variable "tf_deployer_sa_name" {}
# Terraform Deployer SA Permissions
variable "tf_deployer_sa_permissions" {}

# Api to enable
variable "services_to_enable" {}