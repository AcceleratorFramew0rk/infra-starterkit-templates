# This is the module call
module "apim" {
  source  = "Azure/avm-res-apimanagement-service/azurerm"
  # version = "0.0.1"
  version = "0.0.4"

  name                = "${module.naming.user_assigned_identity.name}-${random_string.this.result}"
  resource_group_name          = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  location                     = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location
  publisher_email      = try(var.publisher_email, "company@terraform.io") 
  publisher_name       = try(var.publisher_name, "Apim Publisher") 
  sku_name             = try(var.sku_name, null) != null ? var.sku_name :  try(local.global_settings.environment, var.environment) != "prd" ? "Developer_1" : "Premium"
  enable_telemetry     = var.enable_telemetry # see variables.tf
  virtual_network_type = "Internal"
  virtual_network_subnet_id = try(local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.subnet_name].resource.id, null) != null ? local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.subnet_name].resource.id : var.subnet_id 

  diagnostic_settings = {
    log1 = {
      workspace_resource_id    = try(local.remote.log_analytics_workspace.id, null) != null ? local.remote.log_analytics_workspace.id : var.log_analytics_workspace_id 
    }
  }

  tags                = merge(
    local.global_settings.tags,
    {
      purpose = "api management" 
      project_code = try(local.global_settings.prefix, var.prefix) 
      env = try(local.global_settings.environment, var.environment) 
      zone = "project"
      tier = "app"   
    }
  ) 

}
