
module "plz_storage_blob" {
  source                = "Azure/avm-res-network-privatednszone/azurerm"   
  version = "0.3.3" 

  count = try(local.storageaccount.privatednszone.id, null) == null ? 1 : 0   

  enable_telemetry      = true
  resource_group_name   = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  domain_name           = "privatelink.blob.core.windows.net"
  # number_of_record_sets = 2

  tags        = merge(
    local.global_settings.tags,
    {
      purpose = "storage account private dns zone" 
      project_code = try(local.global_settings.prefix, var.prefix) 
      env = try(local.global_settings.environment, var.environment) 
      zone = "project"
      tier = "db"   
    }
  ) 

  virtual_network_links = {

      dnslink_agent = {
        vnetlinkname = "privatelink.search.windows.net.agent"
        vnetid           = azurerm_virtual_network.vnet.id  

        tags        = merge(
          local.global_settings.tags,
          {
            purpose = "storage vnet link" 
            project_code = try(local.global_settings.prefix, var.prefix) 
            env = try(local.global_settings.environment, var.environment) 
            zone = "project"
            tier = "app"   
          }
        )        
      }  
    }
}  

resource "azurerm_private_dns_zone_virtual_network_link" "plz_storage_account_link" {

  count = try(local.storageaccount.privatednszone.id, null) == null ? 0 : 1   

  name                  = "privatelink.search.windows.net.agent"
  resource_group_name   = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  private_dns_zone_name = local.storageaccount.privatednszone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false

}

module "storage_account" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.6.4"

  name                = replace("${module.naming.storage_account.name}aiagent${random_string.this.result}", "-", "")  
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

  private_endpoints = {
    blob = {
      name                          = replace("${module.naming.storage_account.name}aiagent${random_string.this.result}blobprivateendpoint", "-", "")  # "pe-storage-blob"
      subnet_resource_id            = azurerm_subnet.subnet_pe.id 
      subresource_name              = "blob"
      private_dns_zone_resource_ids = [try(local.storageaccount.privatednszone.id, null) == null ? module.plz_storage_blob.0.resource_id : local.storageaccount.privatednszone.id] 
      inherit_lock                  = false
    }
    # file = {
    #   name                          = "pe-storage-file"
    #   subnet_resource_id            = try(local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.private_endpoint_subnet_name].resource.id, null) != null ? local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.private_endpoint_subnet_name].resource.id : var.private_endpoint_subnet_id 

    #   subresource_name              = "file"
    #   private_dns_zone_resource_ids = [module.private_dns_storageaccount_file.resource_id]
    #   inherit_lock                  = false
    # }
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
  depends_on = [module.plz_storage_blob]    
}

module "diagnosticsetting1" {
  source = "AcceleratorFramew0rk/aaf/azurerm//modules/diagnostics/terraform-azurerm-diagnosticsetting"  

  name                = "${module.naming.monitor_diagnostic_setting.name_unique}-storageaccount"
  target_resource_id = module.storage_account.resource.id
  log_analytics_workspace_id = try(local.remote.log_analytics_workspace.id, null) != null ? local.remote.log_analytics_workspace.id : var.log_analytics_workspace_id
  diagnostics = {
    categories = {
      # log = [
      #   # ["Category name",  "Diagnostics Enabled(true/false)", "Retention Enabled(true/false)", Retention_period]
      #   ["DiagnosticErrorLogs", true, false, 7],          
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
