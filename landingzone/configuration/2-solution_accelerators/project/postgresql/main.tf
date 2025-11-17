module "private_dns_zones" {
  source                = "Azure/avm-res-network-privatednszone/azurerm"   
  # version = "0.1.2"
  version = "0.3.3"

  enable_telemetry      = true
  resource_group_name   = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  domain_name           = "privatelink.postgres.database.azure.com"
  tags         = merge(
    local.global_settings.tags,
    {
      purpose = "postgresql server dns zone" 
      project_code = try(local.global_settings.prefix, var.prefix) 
      env = try(local.global_settings.environment, var.environment) 
      zone = "project"
      tier = "db"   
    }
  )
  virtual_network_links = {
      vnetlink1 = {
        vnetlinkname     = "vnetlink1"
        vnetid           = try(local.remote.networking.virtual_networks.spoke_project.virtual_network.id, null) != null ? local.remote.networking.virtual_networks.spoke_project.virtual_network.id : var.vnet_id  
        autoregistration = false # true
        tags = merge(
          local.global_settings.tags,
          {
            purpose = "postgresql server vnet link" 
            project_code = try(local.global_settings.prefix, var.prefix) 
            env = try(local.global_settings.environment, var.environment) 
            zone = "project"
            tier = "service"   
          }
        )
      }
      vnetlink2 = {
        vnetlinkname     = "vnetlink2"
        vnetid           = try(local.remote.networking.virtual_networks.spoke_devops.virtual_network.id, null) != null ? local.remote.networking.virtual_networks.spoke_devops.virtual_network.id : var.vnet_id  
        autoregistration = false # true
        tags = merge(
          local.global_settings.tags,
          {
            purpose = "postgresql server vnet link" 
            project_code = try(local.global_settings.prefix, var.prefix) 
            env = try(local.global_settings.environment, var.environment) 
            zone = "project"
            tier = "service"   
          }
        )
      }      
    }
}

# This is the module call
# Do not specify location here due to the randomization above.
# Leaving location as `null` will cause the module to use the resource group location
# with a data source.
module "postgresql" {
  # source = "../../"
  source  = "Azure/avm-res-dbforpostgresql-flexibleserver/azurerm"
  # version = "0.1.2" 
  version = "0.1.4"

  location               = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location
  name                   = "${module.naming.postgresql_server.name_unique}${random_string.this.result}" # module.naming.postgresql_server.name_unique
  resource_group_name    = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  enable_telemetry       = var.enable_telemetry
  administrator_login    = "psqladmin"
  administrator_password =  random_password.sql_admin.result # "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" # random_password.myadminpassword.result
  server_version         = var.server_version #16
  sku_name               = var.sku_name # "GP_Standard_D2s_v3"
  zone                   = var.zone # 1
  high_availability = {
    mode                      = "ZoneRedundant"
    standby_availability_zone = 2
  }
  firewall_rules = {} # no firewall rules since we are using private endpoint

  private_endpoints = {
    primary = {
      name                           = "${module.postgresql.name}-pep"
      private_dns_zone_resource_ids = [module.private_dns_zones.resource.id] 
      subnet_resource_id            = try(local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.subnet_name].resource.id, null) != null ? local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.subnet_name].resource.id : var.subnet_id  
      subresource_name = "postgresqlServer" 
    }
  }

  tags                           = merge(
    local.global_settings.tags,
    {
      purpose = "postgresql server" 
      project_code = try(local.global_settings.prefix, var.prefix) 
      env = try(local.global_settings.environment, var.environment) 
      zone = "project"
      tier = "db"   
    }
  ) 


  depends_on = [
    module.private_dns_zones,
    module.keyvault
  ]  

}
