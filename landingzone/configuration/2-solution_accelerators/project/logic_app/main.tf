resource "azurerm_app_service_plan" "this" {
  name                         = "${module.naming.app_service_plan.name}-logicapp"
  location                     = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location
  resource_group_name          = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  kind                         = "elastic" # "Linux"
  maximum_elastic_worker_count = 5 

  # For kind=Linux must be set to true and for kind=Windows must be set to false
  reserved         = true 

  sku {
    tier     = try(var.tier,"WorkflowStandard") # "WorkflowStandard" # "Standard"
    size     = try(var.size, "WS1") # "WS1, S1"
  }

  tags        = merge(
    local.global_settings.tags,
    {
      purpose = "logic app asp" 
      project_code = try(local.global_settings.prefix, var.prefix) 
      env = try(local.global_settings.environment, var.environment) 
      zone = "project"
      tier = "app"   
    }
  )

}

# this is not required if app service exists - use azurerm resource logic - do not use AVM
module "private_dns_zones" {
  source                = "Azure/avm-res-network-privatednszone/azurerm"   
  # version = "0.1.2" 
  version = "0.3.3"

  # execute this module if private dns zone from app service module is not available
  count = try(local.privatednszone.id, null) == null ? 1 : 0 

  enable_telemetry      = true
  resource_group_name   = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  domain_name           = "privatelink.azurewebsites.net"
  tags        = merge(
    local.global_settings.tags,
    {
      purpose = "logic app private dns zone" 
      project_code = try(local.global_settings.prefix, var.prefix) 
      env = try(local.global_settings.environment, var.environment) 
      zone = "project"
      tier = "app"   
    }
  ) 
  virtual_network_links = {
      vnetlink1 = {
        vnetlinkname     = "vnetlink1"
        vnetid           = try(local.remote.networking.virtual_networks.spoke_project.virtual_network.id, null) != null ? local.remote.networking.virtual_networks.spoke_project.virtual_network.id : var.vnet_id  
        autoregistration = false # true
        tags = {
          "env" = "dev"
        }
      }
    }
}

# module "private_endpoint" {
#   # source = "./../../../../../../modules/terraform-azurerm-aaf/modules/networking/terraform-azurerm-privateendpoint"
#   source = "AcceleratorFramew0rk/aaf/azurerm//modules/networking/terraform-azurerm-privateendpoint"
 
#   name                           = "${module.logicapp.resource.name}-privateendpoint"
#   location                       = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location
#   resource_group_name            = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
#   subnet_id                      = try(local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.ingress_subnet_name].resource.id, null) != null ? local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.ingress_subnet_name].resource.id : var.ingress_subnet_id 
#   tags        = merge(
#     local.global_settings.tags,
#     {
#       purpose = "logic app private endpoint" 
#       project_code = try(local.global_settings.prefix, var.prefix) 
#       env = try(local.global_settings.environment, var.environment) 
#       zone = "project"
#       tier = "app"   
#     }
#   ) 
#   private_connection_resource_id = module.logicapp.resource.id
#   is_manual_connection           = false
#   subresource_name               = "sites"
#   private_dns_zone_group_name    = "default" 
#   # private dns using either from solution accelerator app service or local
#   private_dns_zone_group_ids     = [try(local.privatednszone.id, null) == null ? module.private_dns_zones.0.resource.id : local.privatednszone.id ] # [module.private_dns_zones.0.resource.id] #   [module.private_dns_zones.resource.id] 
# }

# resource "azurerm_user_assigned_identity" "this" {
#   location            = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location
#   # name                = module.naming.user_assigned_identity.name_unique
#   name                = "${module.naming.user_assigned_identity.name}-logic-${random_string.this.result}"
#   resource_group_name = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
# }

# module "logicapp" {
#   # source = "./../../../../../../modules/terraform-azurerm-aaf/modules/logic_app/standard"  
#   source = "AcceleratorFramew0rk/aaf/azurerm//modules/logic_app/standard"

#   # insert the 4 required variables here

#   name                         = "${module.naming.logic_app_workflow.name}-${random_string.this.result}" # alpha numeric characters only are allowed in "name var.name_prefix == null ? "${random_string.prefix.result}${var.acr_name}" : "${var.name_prefix}${var.acr_name}"
#   resource_group_name          = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
#   location                     = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location

#   app_service_plan_id = azurerm_app_service_plan.this.id

#   # Required for virtual network integration
#   subnet_id                      = try(local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.subnet_name].resource.id, null) != null ? local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.subnet_name].resource.id : var.subnet_id 

#   identity = {
#     type = "UserAssigned" # "SystemAssigned, UserAssigned"
#     identity_ids = [azurerm_user_assigned_identity.this.id]
#   }

#   app_settings = {
#     "FUNCTIONS_WORKER_RUNTIME"     = "node",
#     "WEBSITE_NODE_DEFAULT_VERSION" = "~18",
#   }

#   # site_config = {
#   #   linux_fx_version = "DOCKER|mcr.microsoft.com/azure-functions/dotnet:3.0-appservice"
#   # }

#   tags        = merge(
#     local.global_settings.tags,
#     {
#       purpose = "logic app" 
#       project_code = try(local.global_settings.prefix, var.prefix) 
#       env = try(local.global_settings.environment, var.environment) 
#       zone = "project"
#       tier = "app"   
#     }
#   )  


# }

resource "azurerm_storage_account" "this" {
  account_replication_type = "LRS"
  account_tier             = "Standard"
  name                     = replace(replace("${module.naming.storage_account.name_unique}la${random_string.this.result}", "-", ""), "_", "")
  resource_group_name          = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  location                     = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location

  network_rules {
    default_action = "Allow"
    bypass         = ["AzureServices"]
  }
}

data "azurerm_role_definition" "this" {
  name = "Contributor"
}

module "logicapp" {
  source  = "Azure/avm-res-web-site/azurerm"
  # version = "0.17.0"
  version = "0.17.2"
  # insert the 6 required variables here

  kind     = "logicapp"

  # location = azurerm_resource_group.example.location
  # name     = "${module.naming.logic_app_workflow.name_unique}-logicapp" # Likely to change naming in the future
  # resource_group_name      = azurerm_resource_group.example.name

  name                         = "${module.naming.logic_app_workflow.name}-${random_string.this.result}" # alpha numeric characters only are allowed in "name var.name_prefix == null ? "${random_string.prefix.result}${var.acr_name}" : "${var.name_prefix}${var.acr_name}"
  resource_group_name          = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  location                     = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location

  # identity = {
  #   type = "UserAssigned" # "SystemAssigned, UserAssigned"
  #   identity_ids = [azurerm_user_assigned_identity.this.id]
  # }

  # Uses an existing app service plan
  os_type                  = "Linux" # azurerm_app_service_plan.this.os_type
  service_plan_resource_id = azurerm_app_service_plan.this.id
  app_settings = {
    FUNCTIONS_RUNTIME_WORKER     = "node"
    WEBSITE_NODE_DEFAULT_VERSION = "~18"
  }
  application_insights = {
    workspace_resource_id = try(local.remote.log_analytics_workspace.id, null) != null ? local.remote.log_analytics_workspace.id : var.log_analytics_workspace_id # azurerm_log_analytics_workspace.example.id
  }
  enable_telemetry = var.enable_telemetry
  private_endpoints = {
    # Use of private endpoints requires Standard SKU
    primary = {
      name                          = "${module.logicapp.resource.name}-privateendpoint" # "primary-interfaces"
      private_dns_zone_resource_ids = [try(local.privatednszone.id, null) == null ? module.private_dns_zones.0.resource.id : local.privatednszone.id ]  # [azurerm_private_dns_zone.example.id]
      subnet_resource_id            = try(local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.ingress_subnet_name].resource.id, null) != null ? local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.ingress_subnet_name].resource.id : var.ingress_subnet_id  # azurerm_subnet.example.id
      tags        = merge(
        local.global_settings.tags,
        {
          purpose = "logic app private endpoint" 
          project_code = try(local.global_settings.prefix, var.prefix) 
          env = try(local.global_settings.environment, var.environment) 
          zone = "project"
          tier = "service"   
        }
      ) 
    }
  }
  role_assignments = {
    role_assignment_1 = {
      role_definition_id_or_name = data.azurerm_role_definition.this.id
      principal_id               = data.azurerm_client_config.current.object_id
    }
  }

  site_config = {

  }
  storage_account_access_key = azurerm_storage_account.this.primary_access_key
  # Uses an existing storage account
  storage_account_name = azurerm_storage_account.this.name

  tags        = merge(
    local.global_settings.tags,
    {
      purpose = "logic app private endpoint" 
      project_code = try(local.global_settings.prefix, var.prefix) 
      env = try(local.global_settings.environment, var.environment) 
      zone = "project"
      tier = "service" 
      module  = "Azure/avm-res-web-site/azurerm"
      version = "0.17.0"  
    }
  )  
}
