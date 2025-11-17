output "resource_id" {
  value       = module.aihub.resource_id 
  description = "The Azure ai_foundry resource id"
  sensitive = true  
}

output "global_settings" {
  value       = local.global_settings
  description = "The framework global_settings"
}

