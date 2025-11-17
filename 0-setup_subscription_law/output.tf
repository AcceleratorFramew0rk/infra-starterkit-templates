output "gcci_agency_law" {
  value = azurerm_resource_group.gcci_agency_law
  description = "The resource group for law"
}

output "gcci_agency_workspace" {
  value       = {
    name = module.log_analytics_workspace.name # azurerm_virtual_network.vnet
    id = module.log_analytics_workspace.id
  }
  description = "The log analytics workspace"
}

