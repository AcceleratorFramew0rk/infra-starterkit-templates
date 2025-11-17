module "aisearch" {
  source                        = "Azure/avm-res-search-searchservice/azurerm"
  version                       = "0.2.0"
  location                      = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location
  name                          = replace("${module.naming.search_service.name}aml${random_string.this.result}", "-", "")  
  resource_group_name   = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  enable_telemetry              = var.enable_telemetry
  local_authentication_enabled = false
  managed_identities = {
    system_assigned = true
  }
  sku                           = try(local.global_settings.environment, var.environment) != "prd" ? "basic" : "standard" # basic, free, standard, standard2, standard3, storage_optimized_l1 and storage_optimized_l2. For more details, see https://learn.microsoft.com/en-us/azure/search/search-sku-tier

  # Networking-related controls
  public_network_access_enabled = false # true # false # var.public_network_access_enabled # false
  allowed_ips = concat(
      var.ingress_client_ip,
      var.deployment_machine_ips,
      [local.aisearch_portal_ip],
      [local.my_public_ip]
    )
  network_rule_bypass_option = "AzureServices" # Possible values null or AzureServices      

  diagnostic_settings = {
    diag = {
      name                  = "${module.naming.monitor_diagnostic_setting.name_unique}-amlaisearch"
      workspace_resource_id = try(local.remote.log_analytics_workspace.id, null) != null ? local.remote.log_analytics_workspace.id : var.log_analytics_workspace_id
    }
  }

  tags        = merge(
    local.global_settings.tags,
    {
      purpose = "search service" 
      project_code = try(local.global_settings.prefix, var.prefix) 
      env = try(local.global_settings.environment, var.environment) 
      zone = "project"
      tier = "app"   
    }
  ) 
}

