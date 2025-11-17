output "resource" {
  value       = {
    id = module.keyvault.resource_id, 
    name = module.keyvault.name, 
   }
  description = "The Azure keyvault resource"
  sensitive = true  
}


output "resource_id" {
  value = module.keyvault.resource_id
  description = "The Azure keyvault resource id"
  sensitive = true  
}

output "name" {
  value = module.keyvault.name
  description = "The Azure keyvault resource name"
  sensitive = true  
}

output "global_settings" {
  value       = local.global_settings
  description = "The framework global_settings"
}

output "private_dns_zones_resource" {
  value       = module.private_dns_zones.resource 
  description = "The Azure private_dns_zones resource"
  sensitive = true  
}
