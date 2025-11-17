# output "resource" {
#   value       = azapi_resource.ai_foundry
#   description = "The Azure AI Foundry resource"
#   sensitive = true  
# }

output "global_settings" {
  value       = local.global_settings
  description = "The framework global_settings"
}

