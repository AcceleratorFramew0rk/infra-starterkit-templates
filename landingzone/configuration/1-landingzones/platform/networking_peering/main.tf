# internet ingress - management spoke peering
resource "azurerm_virtual_network_peering" "internet_ingress_peer_management" {
  
  count = try(local.remote.networking.virtual_networks.hub_internet_ingress.virtual_network.name, null) != null && try(local.remote.networking.virtual_networks.spoke_management.virtual_network.id, null) != null ? 1 : 0

  name                         = "${module.naming.virtual_network_peering.name}${random_string.this.result}-internet-ingress-peer-management" 
  resource_group_name          = local.remote.resource_group.name
  virtual_network_name         = local.remote.networking.virtual_networks.hub_internet_ingress.virtual_network.name  
  remote_virtual_network_id    = local.remote.networking.virtual_networks.spoke_management.virtual_network.id  
  allow_virtual_network_access = true 
  allow_forwarded_traffic      = true 
  allow_gateway_transit        = false
  use_remote_gateways          = false 
}

resource "azurerm_virtual_network_peering" "management_peer_internet_ingress" {

  count = try(local.remote.networking.virtual_networks.spoke_management.virtual_network.name, null) != null && try(local.remote.networking.virtual_networks.hub_internet_ingress.virtual_network.id, null) != null ? 1 : 0

  name                         = "${module.naming.virtual_network_peering.name}${random_string.this.result}-management-peer-internet-ingress" 
  resource_group_name          = local.remote.resource_group.name
  virtual_network_name         = local.remote.networking.virtual_networks.spoke_management.virtual_network.name  
  remote_virtual_network_id    = local.remote.networking.virtual_networks.hub_internet_ingress.virtual_network.id  
  allow_virtual_network_access = true 
  allow_forwarded_traffic      = true 
  allow_gateway_transit        = false
  use_remote_gateways          = false 
}

# intranet ingress - management spoke peering
resource "azurerm_virtual_network_peering" "intranet_ingress_peer_management" {
  
  count = try(local.remote.networking.virtual_networks.hub_intranet_ingress.virtual_network.name, null) != null && try(local.remote.networking.virtual_networks.spoke_management.virtual_network.id, null) != null ? 1 : 0

  name                         = "${module.naming.virtual_network_peering.name}${random_string.this.result}-intranet-ingress-peer-management" 
  resource_group_name          = local.remote.resource_group.name
  virtual_network_name         = local.remote.networking.virtual_networks.hub_intranet_ingress.virtual_network.name  
  remote_virtual_network_id    = local.remote.networking.virtual_networks.spoke_management.virtual_network.id  
  allow_virtual_network_access = true 
  allow_forwarded_traffic      = true 
  allow_gateway_transit        = false
  use_remote_gateways          = false 
}

resource "azurerm_virtual_network_peering" "management_peer_intranet_ingress" {

  count = try(local.remote.networking.virtual_networks.spoke_management.virtual_network.name, null) != null && try(local.remote.networking.virtual_networks.hub_intranet_ingress.virtual_network.id, null) != null ? 1 : 0

  name                         = "${module.naming.virtual_network_peering.name}${random_string.this.result}-management-peer-intranet-ingress" 
  resource_group_name          = local.remote.resource_group.name
  virtual_network_name         = local.remote.networking.virtual_networks.spoke_management.virtual_network.name  
  remote_virtual_network_id    = local.remote.networking.virtual_networks.hub_intranet_ingress.virtual_network.id  
  allow_virtual_network_access = true 
  allow_forwarded_traffic      = true 
  allow_gateway_transit        = false
  use_remote_gateways          = false 
}
