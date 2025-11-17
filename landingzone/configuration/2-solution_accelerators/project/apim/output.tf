output "resource" {
  value       = module.apim.resource 
  description = "The Azure Apim resource"
  sensitive = true  
}

output "global_settings" {
  value       = local.global_settings
  description = "The framework global_settings"
}
