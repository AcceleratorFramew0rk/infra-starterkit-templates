output "resource" {
  value       = module.cosmos_db
  description = "The Azure cosmos_db resource"
  sensitive = true  
}

output "global_settings" {
  value       = local.global_settings
  description = "The framework global_settings"
}
