provider "azurerm" {
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
    azapi = {
      source = "azure/azapi"
      # version = "~> 1.0"
      version = ">= 1.9.0"
    }    
  }
  backend "azurerm" {}
}
