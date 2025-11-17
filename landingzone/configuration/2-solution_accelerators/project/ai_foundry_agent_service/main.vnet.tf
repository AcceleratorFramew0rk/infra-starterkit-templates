
## Create a virtual network for the AI Foundry resource and supporting resources
##
resource "azurerm_virtual_network" "vnet" {
  name                  = "${module.naming.virtual_network.name}-aiagent" 
  location            = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location # azurerm_resource_group.this.0.location
  resource_group_name = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name # azurerm_resource_group.this.0.name
  address_space = [
    var.virtual_network_address_space
  ]
}

## Create two subnets one for the Standard Agent VNet injection and one for the AI Foundry resource
##
resource "azurerm_subnet" "subnet_agent" {
  name                  = "AgentSubnet" 
  resource_group_name = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name # azurerm_resource_group.this.0.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = [
    var.agent_subnet_address_prefix
  ]
  delegation {
    name = "Microsoft.App/environments"
    service_delegation {
      name = "Microsoft.App/environments"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}

resource "azurerm_subnet" "subnet_pe" {
  name                  = "PrivateEndpointSubnet" 
  resource_group_name = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name # azurerm_resource_group.this.0.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = [
    var.private_endpoint_subnet_address_prefix
  ]
}

# peering agent - project
resource "azurerm_virtual_network_peering" "agent_peer_project" {

  name                         = "${module.naming.virtual_network_peering.name}${random_string.this.result}agent-peer-project" 
  resource_group_name = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name 
  virtual_network_name         = azurerm_virtual_network.vnet.name  
  remote_virtual_network_id    = local.remote.networking.virtual_networks.spoke_project.virtual_network.id  
  allow_virtual_network_access = true 
  allow_forwarded_traffic      = true 
  allow_gateway_transit        = false
  use_remote_gateways          = false 
}


# peering project - agent
resource "azurerm_virtual_network_peering" "project_peer_agent" {

  name                         = "${module.naming.virtual_network_peering.name}${random_string.this.result}project-peer-agent" 
  resource_group_name          = local.remote.resource_group.name
  virtual_network_name         = local.remote.networking.virtual_networks.spoke_project.virtual_network.name  
  remote_virtual_network_id    = azurerm_virtual_network.vnet.id 
  allow_virtual_network_access = true 
  allow_forwarded_traffic      = true 
  allow_gateway_transit        = false
  use_remote_gateways          = false 
}
