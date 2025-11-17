# Create private endpoint to SHIP-HATS

# Private endpoint

# Resource:
# Connection Method	Choose Connect to an Azure resource by resource ID or alias.
# Resource ID or Alias	Specify /subscriptions/0bf6396d-d121-42c6-aa7f-37f39cc52de7/resourceGroups/shiphats-prod-privatelink/providers/Microsoft.Network/applicationGateways/shiphats-prod-proxy-appgw.
# Target Sub-Resource	Specify PrivateFrontendIp.
# Request Message	Specify Request from <PROJECT_NAME>.

# Network:
# Field	Information
# Subnet	Select the required subnet to provision the private endpoint.
# Private IP configuration	Choose Dynamically allocate IP address.

# Create a Private DNS zone

# Field	Information
# Resource Group	Select the required resource group.
# Name	Enter ship.gov.sg.

# DNS Zone	Name
# ship.gov.sg	*
# hats.stack.gov.sg	*
# sgts.gitlab-dedicated.com	registry
# sgts.gitlab-dedicated.com	@


# To verify Azure Private Link endpoint connectivity

# Log in to a virtual machine.
# Verify connectivity with the following curl commands:
# curl -v https://sgts.gitlab-dedicated.com
# curl -v https://sonar.hats.stack.gov.sg
# curl -v https://nexus-docker.ship.gov.sg

# hats.stack.gov.sg
# sgts.gitlab-dedicated.com
# ship.gov.sg


# module "aaaa_record" {
#   source   = "./modules/private_dns_aaaa_record"
#   for_each = var.aaaa_records

#   ip_addresses = coalesce(each.value.ip_addresses, toset(each.value.records))
#   name         = each.value.name
#   parent_id    = azapi_resource.private_dns_zone.id
#   ttl          = each.value.ttl
#   timeouts     = var.timeouts.dns_zones
# }


module "private_dns_ship_gov_sg" {
  source              = "Azure/avm-res-network-privatednszone/azurerm"
  # version             = "~> 0.2"
  version = "0.3.5"
  domain_name         = "ship.gov.sg"
  resource_group_name   = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  virtual_network_links = {
    dnslink = {
      vnetlinkname = "ship.gov.sg"
      vnetid           = try(local.remote.networking.virtual_networks.spoke_devops.virtual_network.id, null) != null ? local.remote.networking.virtual_networks.spoke_devops.virtual_network.id : var.vnet_id
    }
  }
  aaaa_records = {
    ip_addresses = toset([""])
    records     = toset([""])
    name        = "*"
    ttl         = 60
  }

  tags        = merge(
    local.global_settings.tags,
    {
      purpose = "ship.gov.sg private dns zone" 
      project_code = try(local.global_settings.prefix, var.prefix) 
      env = try(local.global_settings.environment, var.environment) 
      zone = "devops"
      tier = "app"   
    }
  ) 
  enable_telemetry = var.enable_telemetry
}

module "private_dns_gitlab_dedicated_com" {
  source              = "Azure/avm-res-network-privatednszone/azurerm"
  # version             = "~> 0.2"
  version = "0.3.5"
  domain_name         = "gitlab-dedicated.com"
  resource_group_name   = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  virtual_network_links = {
    dnslink = {
      vnetlinkname = "gitlab-dedicated.com"
      vnetid           = try(local.remote.networking.virtual_networks.spoke_devops.virtual_network.id, null) != null ? local.remote.networking.virtual_networks.spoke_devops.virtual_network.id : var.vnet_id
    }
  }
  tags        = merge(
    local.global_settings.tags,
    {
      purpose = "gitlab-dedicated.com private dns zone" 
      project_code = try(local.global_settings.prefix, var.prefix) 
      env = try(local.global_settings.environment, var.environment) 
      zone = "devops"
      tier = "app"   
    }
  ) 
  enable_telemetry = var.enable_telemetry
}

module "private_dns_stack_gov_sg" {
  source              = "Azure/avm-res-network-privatednszone/azurerm"
  # version             = "~> 0.2"
  version = "0.3.5"
  domain_name         = "stack.gov.sg"
  resource_group_name   = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  virtual_network_links = {
    dnslink = {
      vnetlinkname = "stack.gov.sg"
      vnetid           = try(local.remote.networking.virtual_networks.spoke_devops.virtual_network.id, null) != null ? local.remote.networking.virtual_networks.spoke_devops.virtual_network.id : var.vnet_id
    }
  }
  tags        = merge(
    local.global_settings.tags,
    {
      purpose = "stack.gov.sg private dns zone" 
      project_code = try(local.global_settings.prefix, var.prefix) 
      env = try(local.global_settings.environment, var.environment) 
      zone = "devops"
      tier = "app"   
    }
  ) 
  enable_telemetry = var.enable_telemetry
}

module "private_endpoint_ship_gov_sg" {
  # source = "./../../../../../../modules/terraform-azurerm-aaf/modules/networking/terraform-azurerm-privateendpoint"
  source = "AcceleratorFramew0rk/aaf/azurerm//modules/networking/terraform-azurerm-privateendpoint"

  name                           = "${module.naming.private_endpoint.name}-ship-gov-sg-${random_string.this.result}" 
  location                       = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location
  resource_group_name            = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  subnet_id                      = try(local.remote.networking.virtual_networks[var.vnet_name].virtual_subnets[var.subnet_name].resource.id, null) != null ? local.remote.networking.virtual_networks[var.vnet_name].virtual_subnets[var.subnet_name].resource.id : var.subnet_id
  tags                           = merge(
    local.global_settings.tags,
    {
      purpose = "ship.gov.sg private endpoint" 
      project_code = try(local.global_settings.prefix, var.prefix) 
      env = try(local.global_settings.environment, var.environment) 
      zone = "devops"
      tier = "app"   
    }
  ) 
  private_connection_resource_id = var.ship_hats_resource_id
  is_manual_connection           = false
  subresource_name               = "PrivateFrontendIp" 
  private_dns_zone_group_name    = "shipgovsgprivatednszonegroup"
  private_dns_zone_group_ids     = [module.private_dns_ship_gov_sg.resource.id] 
  
  depends_on = [
    time_sleep.wait_for_a_while,
    module.private_dns_ship_gov_sg, 
    module.private_dns_gitlab_dedicated_com, 
    module.private_dns_stack_gov_sg
  ]

}

module "private_endpoint_gitlab_dedicated_com" {
  # source = "./../../../../../../modules/terraform-azurerm-aaf/modules/networking/terraform-azurerm-privateendpoint"
  source = "AcceleratorFramew0rk/aaf/azurerm//modules/networking/terraform-azurerm-privateendpoint"

  name                           = "${module.naming.private_endpoint.name}-gitlab-dedicated-com-${random_string.this.result}" 
  location                       = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location
  resource_group_name            = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  subnet_id                      = try(local.remote.networking.virtual_networks[var.vnet_name].virtual_subnets[var.subnet_name].resource.id, null) != null ? local.remote.networking.virtual_networks[var.vnet_name].virtual_subnets[var.subnet_name].resource.id : var.subnet_id
  tags                           = merge(
    local.global_settings.tags,
    {
      purpose = "gitlab-dedicated.com private endpoint" 
      project_code = try(local.global_settings.prefix, var.prefix) 
      env = try(local.global_settings.environment, var.environment) 
      zone = "devops"
      tier = "app"   
    }
  ) 
  private_connection_resource_id = var.ship_hats_resource_id
  is_manual_connection           = false
  subresource_name               = "PrivateFrontendIp" 
  private_dns_zone_group_name    = "gitlabdedicatedcomprivatednszonegroup"
  private_dns_zone_group_ids     = [module.private_dns_gitlab_dedicated_com.resource.id] 
  
  depends_on = [
    time_sleep.wait_for_a_while,
    module.private_dns_ship_gov_sg, 
    module.private_dns_gitlab_dedicated_com, 
    module.private_dns_stack_gov_sg
  ]

}

module "private_endpoint_stack_gov_sg" {
  # source = "./../../../../../../modules/terraform-azurerm-aaf/modules/networking/terraform-azurerm-privateendpoint"
  source = "AcceleratorFramew0rk/aaf/azurerm//modules/networking/terraform-azurerm-privateendpoint"

  name                           = "${module.naming.private_endpoint.name}-stack-gov-sg-${random_string.this.result}" 
  location                       = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location
  resource_group_name            = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  subnet_id                      = try(local.remote.networking.virtual_networks[var.vnet_name].virtual_subnets[var.subnet_name].resource.id, null) != null ? local.remote.networking.virtual_networks[var.vnet_name].virtual_subnets[var.subnet_name].resource.id : var.subnet_id
  tags                           = merge(
    local.global_settings.tags,
    {
      purpose = "stack.gov.sg private endpoint" 
      project_code = try(local.global_settings.prefix, var.prefix) 
      env = try(local.global_settings.environment, var.environment) 
      zone = "devops"
      tier = "app"   
    }
  ) 
  private_connection_resource_id = var.ship_hats_resource_id
  is_manual_connection           = false
  subresource_name               = "PrivateFrontendIp" 
  private_dns_zone_group_name    = "stackgovsgprivatednszonegroup"
  private_dns_zone_group_ids     = [module.private_dns_stack_gov_sg.resource.id] 

  depends_on = [
    time_sleep.wait_for_a_while,
    module.private_dns_ship_gov_sg, 
    module.private_dns_gitlab_dedicated_com, 
    module.private_dns_stack_gov_sg
  ]

}

# Add a delay after IoT Hub creation
resource "time_sleep" "wait_for_a_while" {
  depends_on = [module.private_dns_stack_gov_sg, module.private_dns_gitlab_dedicated_com, module.private_dns_stack_gov_sg]  
  create_duration = "60s"  # Wait 60 seconds before proceeding
}
