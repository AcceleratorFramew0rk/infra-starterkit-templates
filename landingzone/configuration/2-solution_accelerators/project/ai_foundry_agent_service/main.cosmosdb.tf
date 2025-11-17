module "plz_cosmos_db" {
  source                = "Azure/avm-res-network-privatednszone/azurerm"   
  version = "0.3.3"

  enable_telemetry      = true
  resource_group_name   = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  domain_name           = "privatelink.documents.azure.com"

  tags        = merge(
    local.global_settings.tags,
    {
      purpose = "consmos db private dns zone" 
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
            purpose = "consmos db vnet link" 
            project_code = try(local.global_settings.prefix, var.prefix) 
            env = try(local.global_settings.environment, var.environment) 
            zone = "project"
            tier = "db"   
          }
        )        
      }      
    }
}

module "cosmosdb" {
  source  = "Azure/avm-res-documentdb-databaseaccount/azurerm"
  version = "0.10.0"

  name                = replace("${module.naming.cosmosdb_account.name}aiagent${random_string.this.result}", "-", "") 
  location            = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location
  resource_group_name = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name

  analytical_storage_enabled = true
  automatic_failover_enabled = false
  capacity = {
    total_throughput_limit = -1
  }
  geo_locations = [
    {
      location          = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location # local.location
      failover_priority = 0
      zone_redundant    = false
    }
  ]
  consistency_policy = {
    consistency_level       = "Session"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100001
  }

  managed_identities = {
    system_assigned            = true
  }

  local_authentication_disabled         = true
  multiple_write_locations_enabled      = false
  network_acl_bypass_for_azure_services = true
  partition_merge_enabled               = false
  public_network_access_enabled         = false # true # false

  private_endpoints = {
    primary = {
      name                            = "${module.naming.cosmosdb_account.name}-${random_string.this.result}-sql-private-endpoint"
      private_dns_zone_resource_ids = [module.plz_cosmos_db.resource.id] 
      subnet_resource_id            = azurerm_subnet.subnet_pe.id 
      subresource_name              = "SQL"
      public_network_access_enabled           = false
      private_endpoints_manage_dns_zone_group = false     
      private_service_connection_name = "primary_sql_connection" 
    }
  }

  tags        = merge(
    local.global_settings.tags,
    {
      purpose = "ai foundry agent cosmos db" 
      project_code = try(local.global_settings.prefix, var.prefix) 
      env = try(local.global_settings.environment, var.environment) 
      zone = "project"
      tier = "app"   
    }
  )   
  depends_on = [module.plz_cosmos_db]    
}
