module "plz_ai_search" {
  source              = "Azure/avm-res-network-privatednszone/azurerm"
  version = "0.3.3" 

  domain_name         = "privatelink.search.windows.net"
  resource_group_name   = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  virtual_network_links = {
    dnslink_agent = {
      vnetlinkname = "privatelink.search.windows.net.agent"
      vnetid           = azurerm_virtual_network.vnet.id  

      tags        = merge(
        local.global_settings.tags,
        {
          purpose = "ai search vnet link" 
          project_code = try(local.global_settings.prefix, var.prefix) 
          env = try(local.global_settings.environment, var.environment) 
          zone = "project"
          tier = "app"   
        }
      )        
    }  
  }
  tags        = merge(
    local.global_settings.tags,
    {
      purpose = "search service private dns zone" 
      project_code = try(local.global_settings.prefix, var.prefix) 
      env = try(local.global_settings.environment, var.environment) 
      zone = "project"
      tier = "app"   
    }
  ) 
  enable_telemetry = var.enable_telemetry
}

module "ai_search" {
  source                        = "Azure/avm-res-search-searchservice/azurerm"
  version                       = "0.2.0"
  location                      = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location
  name                          = "${module.naming.search_service.name}-aiagent-${random_string.this.result}" 
  resource_group_name   = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  enable_telemetry              = var.enable_telemetry
  sku                           = try(local.global_settings.environment, var.environment) != "prd" ? "basic" : "standard" # basic, free, standard, standard2, standard3, storage_optimized_l1 and storage_optimized_l2. For more details, see https://learn.microsoft.com/en-us/azure/search/search-sku-tier

  # Networking-related controls
  public_network_access_enabled = true # false # var.public_network_access_enabled # false
  allowed_ips = concat(
      var.ingress_client_ip,
      var.deployment_machine_ips,
      [local.aisearch_portal_ip],
      [local.my_public_ip]
    )
  network_rule_bypass_option = "AzureServices" # Possible values null or AzureServices      

  private_endpoints = {
    primary = {
      name = "${module.naming.search_service.name}-aiagent-${random_string.this.result}-private-endpoint"
      subnet_resource_id            = azurerm_subnet.subnet_pe.id 
      private_dns_zone_resource_ids = [module.plz_ai_search.resource_id]  
      tags        = merge(
        local.global_settings.tags,
        {
          purpose = "ai foundry agent search service private endpoint" 
          project_code = try(local.global_settings.prefix, var.prefix) 
          env = try(local.global_settings.environment, var.environment) 
          zone = "project"
          tier = "app"   
        }
      ) 
    }
  }

  local_authentication_enabled = false
  managed_identities = {
    system_assigned = true
  }

  diagnostic_settings = {
    diag = {
      name                  = "aml${module.naming.monitor_diagnostic_setting.name_unique}-aiagent-aisearch"
      workspace_resource_id = try(local.remote.log_analytics_workspace.id, null) != null ? local.remote.log_analytics_workspace.id : var.log_analytics_workspace_id
    }
  }

  tags        = merge(
    local.global_settings.tags,
    {
      purpose = "ai foundry agent search service" 
      project_code = try(local.global_settings.prefix, var.prefix) 
      env = try(local.global_settings.environment, var.environment) 
      zone = "project"
      tier = "app"   
    }
  ) 
  depends_on = [module.plz_ai_search]    
}


module "knowledge_store_search" {
  source                        = "Azure/avm-res-search-searchservice/azurerm"
  version                       = "0.2.0"
  location                      = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location
  name                          = "${module.naming.search_service.name}-knowledgestore-${random_string.this.result}" 
  resource_group_name   = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  enable_telemetry              = var.enable_telemetry
  sku                           = try(local.global_settings.environment, var.environment) != "prd" ? "basic" : "standard" # basic, free, standard, standard2, standard3, storage_optimized_l1 and storage_optimized_l2. For more details, see https://learn.microsoft.com/en-us/azure/search/search-sku-tier

  # Networking-related controls
  public_network_access_enabled = true # false # var.public_network_access_enabled # false
  allowed_ips = concat(
      var.ingress_client_ip,
      var.deployment_machine_ips,
      [local.aisearch_portal_ip],
      [local.my_public_ip]
    )
  network_rule_bypass_option = "AzureServices" # Possible values null or AzureServices      

  private_endpoints = {
    primary = {
      name = "${module.naming.search_service.name}-knowledgestore-${random_string.this.result}-private-endpoint"
      subnet_resource_id            = azurerm_subnet.subnet_pe.id 
      private_dns_zone_resource_ids = [module.plz_ai_search.resource_id]  
      tags        = merge(
        local.global_settings.tags,
        {
          purpose = "ai foundry agent search service private endpoint" 
          project_code = try(local.global_settings.prefix, var.prefix) 
          env = try(local.global_settings.environment, var.environment) 
          zone = "project"
          tier = "app"   
        }
      ) 
    }
  }

  local_authentication_enabled = false
  managed_identities = {
    system_assigned = true
  }

  diagnostic_settings = {
    diag = {
      name                  = "aml${module.naming.monitor_diagnostic_setting.name_unique}-knowledgestore-aisearch"
      workspace_resource_id = try(local.remote.log_analytics_workspace.id, null) != null ? local.remote.log_analytics_workspace.id : var.log_analytics_workspace_id
    }
  }

  tags        = merge(
    local.global_settings.tags,
    {
      purpose = "ai foundry agent search service" 
      project_code = try(local.global_settings.prefix, var.prefix) 
      env = try(local.global_settings.environment, var.environment) 
      zone = "project"
      tier = "app"   
    }
  ) 
  depends_on = [module.plz_ai_search]    
}

