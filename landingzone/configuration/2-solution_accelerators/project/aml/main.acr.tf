
# This is the module call
module "container_registry" {
  source  = "Azure/avm-res-containerregistry-registry/azurerm"
  version = "0.4.0"

  name                          = replace("${module.naming.container_registry.name}aml${random_string.this.result}", "-", "") # "${module.naming.container_registry.name_unique}${random_string.this.result}" # module.naming.container_registry.name_unique
  location                      = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location
  resource_group_name           = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  public_network_access_enabled = false # true # false
  sku                          = "Premium" # var.sku # "Premium" # ["Basic", "Standard", "Premium"]

  # # TODO: Review the admin_enabled setting
  # # Cloudscape recommendation: Container Registry instances should not have local admin account enabled
  # # This control checks whether the Container Registry instance has admin accounts enabled. The control fails if the Container Registry instance has the "Admin user" setting enabled.
  # # Admin accounts are designed for testing purposes and have full permissions to the registry, which is overly permissive. Instead, authentication to Container Registry instances should be done using Azure Active Directory identities or service principals.
  admin_enabled = false
  # admin_enabled                = true 
 
  network_rule_set = {
    default_action = "Deny"
    ip_rule = [
      {
        ip_range = "${local.my_public_ip}/32"
      },
    ]
  }

  network_rule_bypass_option = "AzureServices"

  diagnostic_settings = {
    log1 = {
      workspace_resource_id    = try(local.remote.log_analytics_workspace.id, null) != null ? local.remote.log_analytics_workspace.id : var.log_analytics_workspace_id 
    }
  }
  tags = merge(
    local.global_settings.tags,
    {
      purpose = "aml container registry" 
      project_code = try(local.global_settings.prefix, var.prefix) 
      env = try(local.global_settings.environment, var.environment) 
      zone = "project"
      tier = "app"   
    }
  ) 

}
