provider "azurerm" {
  # subscription_id = "000000000-0000-0000-0000-00000000000" 
  # ** Setting the ARM_SUBSCRIPTION_ID environment variable before running Terraform.
  # ## export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
  features {}
}

# Configure Terraform backend
terraform {
  required_version = ">= 1.9, < 2.0"  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4, < 5.0.0"
    }  
  }
  
  backend "azurerm" {}
}
