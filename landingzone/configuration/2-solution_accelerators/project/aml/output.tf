output "resource_id" {
  value       = module.azureml.resource_id 
  description = "The Azure machine learning resource id"
  sensitive = true  
}

output "global_settings" {
  value       = local.global_settings
  description = "The framework global_settings"
}

