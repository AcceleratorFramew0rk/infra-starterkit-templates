# module "diagnosticsetting_storage_account" {
#   source = "AcceleratorFramew0rk/aaf/azurerm//modules/diagnostics/terraform-azurerm-diagnosticsetting"  

#   name                = "${module.naming.monitor_diagnostic_setting.name_unique}-storage-account"
#   target_resource_id = azurerm_storage_account.this.id
#   log_analytics_workspace_id = try(local.remote.log_analytics_workspace.id, null) != null ? local.remote.log_analytics_workspace.id : var.log_analytics_workspace_id
#   diagnostics = {
#     categories = {
#       # log = [
#       #   # ["Category name",  "Diagnostics Enabled(true/false)", "Retention Enabled(true/false)", Retention_period]
#       #   ["DiagnosticErrorLogs", true, false, 7],          
#       # ]
#       metric = [
#         #["Category name",  "Diagnostics Enabled(true/false)", "Retention Enabled(true/false)", Retention_period]
#         # ["AllMetrics", true, false, 7],
#         ["Transaction", true, false, 0],
#         ["Capacity", true, false, 0],        
#       ]
#     }
#   }
# }

# module "diagnosticsetting_keyvault" {
#   source = "AcceleratorFramew0rk/aaf/azurerm//modules/diagnostics/terraform-azurerm-diagnosticsetting"  

#   name                = "${module.naming.monitor_diagnostic_setting.name_unique}-keyvault"
#   target_resource_id = azurerm_key_vault.this.id
#   log_analytics_workspace_id = try(local.remote.log_analytics_workspace.id, null) != null ? local.remote.log_analytics_workspace.id : var.log_analytics_workspace_id
#   diagnostics = {
#     categories = {
#       log = [
#         # ["Category name",  "Diagnostics Enabled(true/false)", "Retention Enabled(true/false)", Retention_period]
#         ["AuditEvent", true, false, 14],
#         ["AzurePolicyEvaluationDetails", true, false, 14],
#       ]
#       metric = [
#         #["Category name",  "Diagnostics Enabled(true/false)", "Retention Enabled(true/false)", Retention_period]
#         ["AllMetrics", true, false, 7],
#       ]
#     }
#   }
# }

# module "diagnosticsetting_containerregistry" {
#   source = "AcceleratorFramew0rk/aaf/azurerm//modules/diagnostics/terraform-azurerm-diagnosticsetting"  

#   name                = "${module.naming.monitor_diagnostic_setting.name_unique}-container-registry"
#   target_resource_id = azurerm_container_registry.this.id
#   log_analytics_workspace_id = try(local.remote.log_analytics_workspace.id, null) != null ? local.remote.log_analytics_workspace.id : var.log_analytics_workspace_id
#   diagnostics = {
#     categories = {
#       log = [
#         # ["Category name",  "Diagnostics Enabled(true/false)", "Retention Enabled(true/false)", Retention_period]
#         ["ContainerRegistryRepositoryEvents", true, false, 7],
#         ["ContainerRegistryLoginEvents", true, false, 7],
#       ]
#       metric = [
#         # ["Category name",  "Diagnostics Enabled(true/false)", "Retention Enabled(true/false)", Retention_period]
#         ["AllMetrics", true, false, 7],
#       ]
#     }
#   }
# }