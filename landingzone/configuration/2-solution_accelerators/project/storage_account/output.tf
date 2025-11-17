output "resource" {
  value       = module.storageaccount.resource 
  description = "The Azure storageaccount resource"
  sensitive = true  
}

output "global_settings" {
  value       = local.global_settings
  description = "The framework global_settings"
}

output "private_dns_zone" {
  value       = module.private_dns_zones.resource 
  description = "The Azure storageaccount private_dns_zones resource"
  sensitive = true  
}