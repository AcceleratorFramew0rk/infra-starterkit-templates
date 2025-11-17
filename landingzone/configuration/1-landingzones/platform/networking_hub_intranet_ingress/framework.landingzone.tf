#-------------------------------------------------------------------------------
# ** IMPORTANT: DO NOT CHANGE
#-------------------------------------------------------------------------------
# Example usage
# vnet_id = local.remote.networking.virtual_networks.hub_internet.virtual_network.id  
# vnet_name = local.remote.networking.virtual_networks.hub_internet.virtual_network.name  
# vnet_id = local.remote.networking.virtual_networks.hub_intranet.virtual_network.id  
# vnet_name = local.remote.networking.virtual_networks.hub_intranet.virtual_network.name  
# vnet_id = local.remote.networking.virtual_networks.spoke_devops.virtual_network.id  
# vnet_name = local.remote.networking.virtual_networks.spoke_devops.virtual_network.name  
# vnet_id = local.remote.networking.virtual_networks.spoke_management.virtual_network.id  
# vnet_name = local.remote.networking.virtual_networks.spoke_management.virtual_network.name  
# vnet_id = local.remote.networking.virtual_networks.spoke_project.virtual_network.id  
# vnet_name = local.remote.networking.virtual_networks.spoke_project.virtual_network.name  
# log_analytics_workspace_id = local.remote.log_analytics_workspace.id 
# resource_group_name = local.remote.resource_group.name  
#-------------------------------------------------------------------------------
variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see https://aka.ms/avm/telemetryinfo.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

variable "resource_group_name" {
  type        = string
  default = null
}

variable "storage_account_name" {
  type        = string
  default = null
}

module "landingzone" {
  # source="./../../../../../../modules/terraform-azurerm-aaf"
  source = "AcceleratorFramew0rk/aaf/azurerm"

  resource_group_name  = try(var.resource_group_name, null) == null ? local.resource_group_name : var.resource_group_name 
  storage_account_name = try(var.storage_account_name, null) == null ? local.storage_account_name : var.storage_account_name 
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.3.0"
  prefix = local.global_settings.is_prefix == true ? ["${try(local.global_settings.prefix, var.prefix)}"] : []
  suffix = local.global_settings.is_prefix == true ? [] : ["${try(local.global_settings.prefix, var.prefix)}"] 
  unique-seed            = "random"
  unique-length          = 3
  unique-include-numbers = false  
}

# This allow use to randomize the name of resources
resource "random_string" "this" {
  length  = 3
  special = false
  upper   = false
}

data "azurerm_client_config" "current" {}

# local remote variables
locals {
  global_settings = try(module.landingzone.global_settings, null)   
  remote =  try(module.landingzone.remote, null)   
} 

variable "config_path" {
  description = "Path to the config.yaml file"
  type        = string
  default     = "/tf/avm/config/config.yaml"
}

data "external" "get_backend_config" {
  program = [
    "bash", "-c", <<EOT
      PREFIX=$(yq -r '.prefix' "${var.config_path}")
      RG_NAME="rg-$${PREFIX}-launchpad"
      STG_NAME=$(az storage account list --resource-group "$RG_NAME" --query "[?contains(name, 'tfstate')].[name]" -o tsv 2>/dev/null | head -n 1)
      echo "{\"storage_account_name\": \"$STG_NAME\", \"resource_group_name\": \"$RG_NAME\"}"
    EOT
  ]
}

# Assign the output to a Terraform local variable
locals {
  storage_account_name = data.external.get_backend_config.result["storage_account_name"]
  resource_group_name = data.external.get_backend_config.result["resource_group_name"]  
}

output "storage_account_name" {
  value = local.storage_account_name
}

output "resource_group_name" {
  value = local.resource_group_name
}
