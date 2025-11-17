module "key_vault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "0.10.1"

  name                = replace("${module.naming.key_vault.name}aml${random_string.this.result}", "-", "")
  enable_telemetry    = var.enable_telemetry
  location            = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location 
  resource_group_name = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name 

  tenant_id                       = data.azurerm_client_config.current.tenant_id
  enabled_for_deployment          = true
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  purge_protection_enabled        = true
  soft_delete_retention_days      = 7
  public_network_access_enabled = false
  # Networking-related controls
  network_acls = {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = var.deployment_machine_ips # Allows data plane access to create keys
  }
  wait_for_rbac_before_secret_operations = {
    create = "60s"
  }
  
  diagnostic_settings = {
    diag = {
      name                  = "aml${module.naming.monitor_diagnostic_setting.name_unique}-amlkeyvault"
      workspace_resource_id = try(local.remote.log_analytics_workspace.id, null) != null ? local.remote.log_analytics_workspace.id : var.log_analytics_workspace_id
    }
  }

  tags        = merge(
    local.global_settings.tags,
    {
      purpose = "aml keyvault" 
      project_code = try(local.global_settings.prefix, var.prefix) 
      env = try(local.global_settings.environment, var.environment) 
      zone = "project"
      tier = "app"   
    }
  ) 

}

resource "azurerm_key_vault_access_policy" "this" {
  key_vault_id = module.key_vault.resource_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = ["Get"]
  secret_permissions = ["Get"]
}
