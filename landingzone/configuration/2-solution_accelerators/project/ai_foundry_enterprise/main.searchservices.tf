module "private_dns_aisearch" {
  source              = "Azure/avm-res-network-privatednszone/azurerm"
  version             = "~> 0.2"
  domain_name         = "privatelink.search.windows.net"
  resource_group_name   = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  virtual_network_links = {
    dnslink = {
      vnetlinkname = "privatelink.search.windows.net"
      vnetid           = try(local.remote.networking.virtual_networks.spoke_project.virtual_network.id, null) != null ? local.remote.networking.virtual_networks.spoke_project.virtual_network.id : var.vnet_id  
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

module "aisearch" {
  source                        = "Azure/avm-res-search-searchservice/azurerm"
  version                       = "0.1.5"
  location                      = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location
  name                          = module.naming.search_service.name_unique
  resource_group_name   = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  public_network_access_enabled = var.public_network_access_enabled # false
  enable_telemetry              = var.enable_telemetry

  private_endpoints = {
    primary = {
      # subnet_resource_id            = module.virtual_network.subnets["private_endpoints"].resource_id
      subnet_resource_id                      = try(local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.subnet_name].resource.id, null) != null ? local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.subnet_name].resource.id : var.subnet_id 

      private_dns_zone_resource_ids = [module.private_dns_aisearch.resource_id]
      tags                          = local.tags
    }
  }

  local_authentication_enabled = false
  managed_identities = {
    system_assigned = true
  }

  diagnostic_settings = {
    diag = {
      name                  = "aml${module.naming.monitor_diagnostic_setting.name_unique}-aisearch"
      workspace_resource_id = try(local.remote.log_analytics_workspace.id, null) != null ? local.remote.log_analytics_workspace.id : var.log_analytics_workspace_id
    }
  }

  tags        = merge(
    local.global_settings.tags,
    {
      purpose = "search service" 
      project_code = try(local.global_settings.prefix, var.prefix) 
      env = try(local.global_settings.environment, var.environment) 
      zone = "project"
      tier = "app"   
    }
  ) 
}

