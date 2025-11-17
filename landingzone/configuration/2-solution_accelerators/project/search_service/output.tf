output "resource" {
  value       = module.aisearch.resource 
  description = "The Azure searchservice resource"
  sensitive = true  
}

output "global_settings" {
  value       = local.global_settings
  description = "The framework global_settings"
}
