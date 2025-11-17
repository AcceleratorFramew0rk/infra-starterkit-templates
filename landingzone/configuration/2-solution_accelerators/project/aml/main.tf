resource "azurerm_log_analytics_workspace" "this" {
  location            = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location
  name                = "${module.naming.log_analytics_workspace.name}-aml-${random_string.this.result}" # module.naming.log_analytics_workspace.name_unique
  resource_group_name = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  tags        = merge(
    local.global_settings.tags,
    {
      purpose = "azureml log analytics workspace" 
      project_code = try(local.global_settings.prefix, var.prefix) 
      env = try(local.global_settings.environment, var.environment) 
      zone = "project"
      tier = "app"   
    }
  ) 
}

resource "azurerm_application_insights" "this" {
  application_type    = "web"
  location            = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location
  name                = "${module.naming.application_insights.name}-aml-${random_string.this.result}"
  resource_group_name = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  tags                = local.tags
  workspace_id        = azurerm_log_analytics_workspace.this.id
}

# This is the module call
module "azureml" {
  source  = "Azure/avm-res-machinelearningservices-workspace/azurerm"
  version = "0.8.0"

  location            = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location
  name                = replace("${module.naming.cognitive_account.name}-aml-${random_string.this.result}", "-", "") # local.name
  resource_group_name = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  enable_telemetry    = var.enable_telemetry
  application_insights = {
    resource_id = azurerm_application_insights.this.id
  }
  container_registry = {
    resource_id = module.container_registry.resource_id
  }
  key_vault = {
    resource_id = module.key_vault.resource_id
  }
  storage_account = {
    resource_id = module.storage_account.resource_id
  }
  diagnostic_settings = {
    diag = {
      name                  = "${module.naming.monitor_diagnostic_setting.name_unique}-aml"
      workspace_resource_id = try(local.remote.log_analytics_workspace.id, null) != null ? local.remote.log_analytics_workspace.id : var.log_analytics_workspace_id # azurerm_log_analytics_workspace.diag.id
    }
  }
  public_network_access_enabled = true
  ip_allowlist       = local.ip_allowlist
  tags        = merge(
    local.global_settings.tags,
    {
      purpose = "azure machine learning" 
      project_code = try(local.global_settings.prefix, var.prefix) 
      env = try(local.global_settings.environment, var.environment) 
      zone = "project"
      tier = "app"   
    }
  )   
  workspace_managed_network = {
    isolation_mode = "AllowOnlyApprovedOutbound"
    spark_ready    = false
    firewall_sku   = "Basic"
  }
}

resource "azapi_resource" "search_connection" {
  name      = replace("${module.naming.cognitive_account.name}azureml-srchconn${random_string.this.result}", "-", "") 
  parent_id = module.azureml.resource_id
  type      = "Microsoft.MachineLearningServices/workspaces/connections@2025-07-01-preview"
  body = {
    properties = {
      category      = "CognitiveSearch"
      target        = "https://${module.aisearch.resource.name}.search.windows.net"
      authType      = "AAD"
      isSharedToAll = true
      metadata = {
        ApiType    = "Azure",
        ResourceId = module.aisearch.resource_id
      }
    }
  }

  depends_on = [module.azureml, module.aisearch]
}

