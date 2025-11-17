module "storage_account" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.6.4"

  name                = replace("${module.naming.storage_account.name}aml${random_string.this.result}", "-", "")  
  resource_group_name = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  location            = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location

  access_tier                   = "Hot"
  account_kind                  = "StorageV2"
  account_replication_type      = "ZRS"
  account_tier                  = "Standard"
  public_network_access_enabled = false # true # false
  shared_access_key_enabled     = true # To avoid error due KeyBasedAuthenticationNotPermitted

  managed_identities = {
    system_assigned = true
  }
  # Networking-related controls
  network_rules = {
    bypass         = ["AzureServices"]
    default_action = "Deny"
    ip_rules       = concat(var.deployment_machine_ips, var.ingress_client_ip, [local.my_public_ip])
    private_link_access = [
      {
        endpoint_resource_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourcegroups/*/providers/Microsoft.Search/searchServices/*"
        endpoint_tenant_id   = data.azurerm_client_config.current.tenant_id
      },
      {
        endpoint_resource_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourcegroups/*/providers/Microsoft.CognitiveServices/accounts/*"
        endpoint_tenant_id   = data.azurerm_client_config.current.tenant_id
      }
    ]
  }
  tags        = merge(
    local.global_settings.tags,
    {
      purpose = "ai foundry agent storage account" 
      project_code = try(local.global_settings.prefix, var.prefix) 
      env = try(local.global_settings.environment, var.environment) 
      zone = "project"
      tier = "app"   
    }
  )   

}

module "diagnosticsetting1" {
  source = "AcceleratorFramew0rk/aaf/azurerm//modules/diagnostics/terraform-azurerm-diagnosticsetting"  

  name                = "${module.naming.monitor_diagnostic_setting.name_unique}-amlstorageaccount"
  target_resource_id = module.storage_account.resource.id
  log_analytics_workspace_id = try(local.remote.log_analytics_workspace.id, null) != null ? local.remote.log_analytics_workspace.id : var.log_analytics_workspace_id
  diagnostics = {
    categories = {
      # log = [
      #   # ["Category name",  "Diagnostics Enabled(true/false)", "Retention Enabled(true/false)", Retention_period]
      #   ["DiagnosticErrorLogs", true, false, 7],          
      #   ["OperationalLogs", true, false, 7],          
      #   ["VNetAndIPFilteringLogs", true, false, 7],          
      #   ["RuntimeAuditLogs", true, false, 7],          
      #   ["ApplicationMetricsLogs", true, false, 7], 
      # ]
      metric = [
        #["Category name",  "Diagnostics Enabled(true/false)", "Retention Enabled(true/false)", Retention_period]
        # ["AllMetrics", true, false, 7],
        ["Transaction", true, false, 0],
        ["Capacity", true, false, 0],        
      ]
    }
  }
}
