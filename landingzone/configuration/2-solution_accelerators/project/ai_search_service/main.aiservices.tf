module "private_dns_cognitiveservices" {
  source              = "Azure/avm-res-network-privatednszone/azurerm"
  # version             = "~> 0.2"
  version = "0.3.3"

  domain_name         = "privatelink.cognitiveservices.azure.com"
  resource_group_name   = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  virtual_network_links = {
    dnslink = {
      vnetlinkname = "privatelink.cognitiveservices.azure.com"
      vnetid           = try(local.remote.networking.virtual_networks.spoke_project.virtual_network.id, null) != null ? local.remote.networking.virtual_networks.spoke_project.virtual_network.id : var.vnet_id  
    }
  }
  tags        = merge(
    local.global_settings.tags,
    {
      purpose = "cognitiveservices service private dns zone" 
      project_code = try(local.global_settings.prefix, var.prefix) 
      env = try(local.global_settings.environment, var.environment) 
      zone = "project"
      tier = "app"   
    }
  ) 
  enable_telemetry = var.enable_telemetry
}

module "private_dns_openai" {
  source              = "Azure/avm-res-network-privatednszone/azurerm"
  version             = "~> 0.2"
  domain_name         = "privatelink.openai.azure.com"
  resource_group_name   = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  virtual_network_links = {
    dnslink = {
      vnetlinkname = "privatelink.openai.azure.com"
      vnetid           = try(local.remote.networking.virtual_networks.spoke_project.virtual_network.id, null) != null ? local.remote.networking.virtual_networks.spoke_project.virtual_network.id : var.vnet_id  
    }
  }
  tags        = merge(
    local.global_settings.tags,
    {
      purpose = "openai service private dns zone" 
      project_code = try(local.global_settings.prefix, var.prefix) 
      env = try(local.global_settings.environment, var.environment) 
      zone = "project"
      tier = "app"   
    }
  ) 
  enable_telemetry = var.enable_telemetry
}

module "private_dns_services_ai" {
  source              = "Azure/avm-res-network-privatednszone/azurerm"
  version             = "~> 0.2"
  domain_name         = "privatelink.services.ai.azure.com"
  resource_group_name   = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  virtual_network_links = {
    dnslink = {
      vnetlinkname = "privatelink.services.ai.azure.com"
      vnetid           = try(local.remote.networking.virtual_networks.spoke_project.virtual_network.id, null) != null ? local.remote.networking.virtual_networks.spoke_project.virtual_network.id : var.vnet_id  
    }
  }
  tags        = merge(
    local.global_settings.tags,
    {
      purpose = "ai service private dns zone" 
      project_code = try(local.global_settings.prefix, var.prefix) 
      env = try(local.global_settings.environment, var.environment) 
      zone = "project"
      tier = "app"   
    }
  ) 
  enable_telemetry = var.enable_telemetry
}

module "aiservices" {
  source                             = "Azure/avm-res-cognitiveservices-account/azurerm"
  version                            = "0.6.0"
  resource_group_name   = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  kind                               = "AIServices"
  name                               = replace("${module.naming.cognitive_account.name_unique}${random_string.this.result}", "-", "") 
  location                           = var.ai_services_location # eastus 
  enable_telemetry                   = var.enable_telemetry
  sku_name                           = "S0" # var.sku # "S0"
  public_network_access_enabled      = false # var.public_network_access_enabled # false # true # required for AI Foundry
  local_auth_enabled                 = true
  outbound_network_access_restricted = false
  custom_subdomain_name = replace("${module.naming.cognitive_account.name_unique}${random_string.this.result}aiservices${random_string.this.result}", "-", "")   # ramdom

  # network_acls = {
  #   default_action = "Allow"
  #   ip_rules =  [local.my_public_ip]
  #   # virtual_network_rules = [
  #   #   {
  #   #     subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-rg/providers/Microsoft.Network/virtualNetworks/my-vnet/subnets/my-subnet"
  #   #     ignore_missing_vnet_service_endpoint = true
  #   #   },
  #   #   {
  #   #     subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-rg/providers/Microsoft.Network/virtualNetworks/my-vnet/subnets/another-subnet"
  #   #   }
  #   # ]
  #   # bypass = "AzureServices"
  # }
  # outbound_network_access_restricted = true  

  # identity
  managed_identities = {
    system_assigned = true
  }   

  private_endpoints = {
    primary = {
      subnet_resource_id            = try(local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.subnet_name].resource.id, null) != null ? local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.subnet_name].resource.id : var.subnet_id 
      location                      = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location
      private_dns_zone_resource_ids = [module.private_dns_cognitiveservices.resource_id,
                                       module.private_dns_openai.resource_id,
                                       module.private_dns_services_ai.resource_id]
      tags        = merge(
        local.global_settings.tags,
        {
          purpose = "ai service" 
          project_code = try(local.global_settings.prefix, var.prefix) 
          env = try(local.global_settings.environment, var.environment) 
          zone = "project"
          tier = "ai"   
        }
      ) 
    }
  }

  diagnostic_settings = {
    diag = {
      name                  = "aml${module.naming.monitor_diagnostic_setting.name_unique}-aiservices"
      workspace_resource_id = try(local.remote.log_analytics_workspace.id, null) != null ? local.remote.log_analytics_workspace.id : var.log_analytics_workspace_id
    }
  }

  tags        = merge(
    local.global_settings.tags,
    {
      purpose = "ai services" 
      project_code = try(local.global_settings.prefix, var.prefix) 
      env = try(local.global_settings.environment, var.environment) 
      zone = "project"
      tier = "app"   
    }
  ) 

  depends_on = [
    module.private_dns_cognitiveservices,
    module.private_dns_openai,
    module.private_dns_services_ai
  ]
}

