module "public_ip_firewall1" {
  source  = "Azure/avm-res-network-publicipaddress/azurerm"
  # version = "0.1.0"
  version = "0.2.0"
  
  enable_telemetry    = var.enable_telemetry
  resource_group_name = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  name                = "${module.naming.public_ip.name}-1-fweez"
  location            = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location 
  diagnostic_settings = {
    log1 = {
      workspace_resource_id    = try(local.remote.log_analytics_workspace.id, null) != null ? local.remote.log_analytics_workspace.id : var.log_analytics_workspace_id 
    }
  }  
}

module "public_ip_firewall2" {
  source  = "Azure/avm-res-network-publicipaddress/azurerm"
  # version = "0.1.0"
  version = "0.2.0"

  enable_telemetry    = var.enable_telemetry
  resource_group_name = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  name                = "${module.naming.public_ip.name}-2-fweez"
  location            = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location 
  diagnostic_settings = {
    log1 = {
      workspace_resource_id    = try(local.remote.log_analytics_workspace.id, null) != null ? local.remote.log_analytics_workspace.id : var.log_analytics_workspace_id 
    }
  }  
}

module "firewall" {
  source  = "Azure/avm-res-network-azurefirewall/azurerm"
  # version = "0.1.4"
  version = "0.3.0"
  
  name                = "${module.naming.firewall.name}-egress-internet"
  enable_telemetry    = var.enable_telemetry
  location            = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location
  # resource_group_name = try(local.remote.resource_group.name, null) != null ? local.remote.resource_group.name : var.resource_group_name # firewall must be in the same resource group as virtual network and subnets
  # ** firewall must be in the same resource group as virtual network and subnets - must be the vnet_resource_group_name
  resource_group_name = try(local.global_settings.config.vnet_resource_group.name, null) != null ? local.global_settings.config.vnet_resource_group.name : var.platform_resource_group_name # firewall must be in the same resource group as virtual network and subnets

  firewall_sku_tier   = "Basic" # "Premium" or "Standard"
  firewall_policy_id  = module.firewall_policy.resource.id # bug in avm module which output resource to id or name variable
  firewall_sku_name   = "AZFW_VNet"
  firewall_zones      = ["1", "2", "3"]
  firewall_ip_configuration = [
    {
      name                 = "${module.naming.firewall.name}-fwegressez-ipconfig"
      subnet_id            = try(local.remote.networking.virtual_networks.hub_internet_egress.virtual_subnets["AzureFirewallSubnet"].resource.id, null) != null ? local.remote.networking.virtual_networks.hub_internet_egress.virtual_subnets["AzureFirewallSubnet"].resource.id : var.subnet_id 
      public_ip_address_id = module.public_ip_firewall1.public_ip_id 
    }
  ]

  # firewall_management_ip_configuration is an object and not a list, therefore no []
  firewall_management_ip_configuration = {
    name                 = "${module.naming.firewall.name}-fwegressez-ipconfigmgmt" 
    subnet_id            = try(local.remote.networking.virtual_networks.hub_internet_egress.virtual_subnets["AzureFirewallManagementSubnet"].resource.id, null) != null ? local.remote.networking.virtual_networks.hub_internet_egress.virtual_subnets["AzureFirewallManagementSubnet"].resource.id : var.azurefirewallmanagement_subnet_id 
    public_ip_address_id = module.public_ip_firewall2.public_ip_id 
  }

  diagnostic_settings = {
    log1 = {
      workspace_resource_id    = try(local.remote.log_analytics_workspace.id, null) != null ? local.remote.log_analytics_workspace.id : var.log_analytics_workspace_id 
      name                           = "${module.naming.firewall.name_unique}-ezegress-diagnostic-setting"
      log_analytics_destination_type = "Dedicated" # Or "AzureDiagnostics"
      log_groups        = ["allLogs"]
      metric_categories = ["AllMetrics"]
    }
  }

  tags        = merge(
    local.global_settings.tags,
    {
      purpose = "hub internet egress firewall" 
      project_code = try(local.global_settings.prefix, var.prefix) 
      env = try(local.global_settings.environment, var.environment) 
      zone = "hub internet"
      tier = "na"   
    }
  ) 

  depends_on = [
    module.public_ip_firewall1,
    module.public_ip_firewall2,
    module.firewall_policy        
  ]
}
