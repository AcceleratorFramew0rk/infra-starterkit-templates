module "private_dns_zones" {
  source                = "Azure/avm-res-network-privatednszone/azurerm"   
  # version = "0.1.2" 
  version = "0.3.3"

  enable_telemetry      = true
  resource_group_name   = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  domain_name           = "privatelink.mongo.cosmos.azure.com"

  tags        = merge(
    local.global_settings.tags,
    {
      purpose = "consmos db private dns zone" 
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

        tags        = merge(
          local.global_settings.tags,
          {
            purpose = "consmos db vnet link" 
            project_code = try(local.global_settings.prefix, var.prefix) 
            env = try(local.global_settings.environment, var.environment) 
            zone = "project"
            tier = "db"   
          }
        ) 

      }
    }
}


module "cosmos_db" {
  source  = "Azure/avm-res-documentdb-databaseaccount/azurerm"
  # version = "0.8.0"
  # version = "0.9.0"
  version = "0.10.0"  
  # insert the 3 required variables here

  resource_group_name = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  location            = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location
  name                = "${module.naming.cosmosdb_account.name}-${random_string.this.result}" # module.naming.container_group.name_unique
  mongo_server_version       = "3.6"
  analytical_storage_enabled = true
  
  diagnostic_settings = {
    log1 = {
      workspace_resource_id    = try(local.remote.log_analytics_workspace.id, null) != null ? local.remote.log_analytics_workspace.id : var.log_analytics_workspace_id 
    }
  }

  private_endpoints = {
    primaryMongo = {
      name                            = "${module.naming.cosmosdb_account.name}-${random_string.this.result}-mongo-pep"
      private_dns_zone_resource_ids = [module.private_dns_zones.resource.id] 
      subnet_resource_id            = try(local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.subnet_name].resource.id, null) != null ? local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.subnet_name].resource.id : var.subnet_id 
      subresource_name              = "MongoDB"
      public_network_access_enabled           = false
      private_endpoints_manage_dns_zone_group = false     
      private_service_connection_name = "primary_mongo_connection" 
    }
  }

  tags = merge(
    local.global_settings.tags,
    {
      purpose = "cosmos db" 
      project_code = try(local.global_settings.prefix, var.prefix) 
      env = try(local.global_settings.environment, var.environment) 
      zone = "project"
      tier = "db"   
    }
  ) 

  # dynamic "geo_location" {
  #   for_each = local.normalized_geo_locations

  #   content {
  #     failover_priority = geo_location.value.failover_priority
  #     location          = geo_location.value.location
  #     zone_redundant    = geo_location.value.zone_redundant
  #   }
  # }

  # geo_locations ={
  #   geo_location1 = {
  #     geo_location          = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location
  #     failover_priority = 0
  #     zone_redundant = false
  #   }
  # }  

  geo_locations = [
    {
      location          = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location # "southeastasia"
      failover_priority = 0
      zone_redundant    = false
    }
  ]  

  mongo_databases = {
    empty_database = {
      name       = "empty_database"
      throughput = 400
    }

    database_autoscale_througput = {
      name = "database_autoscale_througput"

      autoscale_settings = {
        max_throughput = 4000
      }
    }

    database_with_fixed_throughput = {
      name       = "database_with_fixed_throughput"
      throughput = 400
    }

    database_with_collections = {
      name       = "database_with_collections"
      throughput = 400

      collections = {
        "collection_fixed_throughput" = {
          name       = "collection_fixed_throughput"
          throughput = 400
        }

        "collection_autoscale" = {
          name = "collection_autoscale"

          autoscale_settings = {
            max_throughput = 4000
          }
        }

        "collections_with_ttl" = {
          name                = "collections_with_ttl"
          default_ttl_seconds = 3600
        }

        "collections_custom_shard_key" = {
          name      = "collections_custom_shard_key"
          shard_key = "_id"
        }

        "collections_index_keys_unique_false" = {
          name = "collections_index_keys_unique_false"

          index = {
            keys   = ["testproperty"]
            unique = false
          }
        }

        "collections_index_keys_unique_true" = {
          name = "collections_index_keys_unique_true"

          index = {
            keys   = ["testproperty"]
            unique = true
          }
        }
      }
    }
  }

  depends_on = [
    module.private_dns_zones
  ]

}



# module "cosmos_db" {
#   # source              = "./../../../../../../modules/terraform-azurerm-aaf/modules/databases/terraform-azurerm-cosmosdb"
#   source = "AcceleratorFramew0rk/aaf/azurerm//modules/databases/terraform-azurerm-cosmosdb"
  
#   resource_group_name = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
#   location            = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location
#   cosmos_account_name = "${module.naming.cosmosdb_account.name}-${random_string.this.result}" 
#   cosmos_api          = "mongo" # var.cosmos_api
  
#   # sql_dbs             = null # var.sql_dbs
#   # sql_db_containers   = null # var.sql_db_containers

#   mongo_dbs            = var.mongo_dbs
#   mongo_db_collections = var.mongo_db_collections  

#   geo_locations ={
#     geo_location1 = {
#       geo_location          = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location
#       failover_priority = 0
#       zone_redundant = false
#     }
#   }

# # /* Mongo API Variables*/
# # variable "mongo_dbs" {
# #   type = map(object({
# #     db_name           = string
# #     db_throughput     = number
# #     db_max_throughput = number
# #   }))
# #   description = "Map of Cosmos DB Mongo DBs to create. Some parameters are inherited from cosmos account."
# #   default     = {}
# # }

# # variable "mongo_db_collections" {
# #   type = map(object({
# #     collection_name           = string
# #     db_name                   = string
# #     default_ttl_seconds       = string
# #     shard_key                 = string
# #     collection_throughout     = number
# #     collection_max_throughput = number
# #     analytical_storage_ttl    = number
# #     indexes = map(object({
# #       mongo_index_keys   = list(string)
# #       mongo_index_unique = bool
# #     }))
# #   }))
# #   description = "List of Cosmos DB Mongo collections to create. Some parameters are inherited from cosmos account."
# #   default     = {}
# # }

#   private_endpoint = {
#     "pe_endpoint" = {
#       dns_zone_group_name             = var.dns_zone_group_name
#       dns_zone_rg_name                = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name 
#       enable_private_dns_entry        = true
#       is_manual_connection            = false
#       name                            = "${module.naming.cosmosdb_account.name}-${random_string.this.result}-privateendpoint" # var.pe_name
#       private_service_connection_name = "${module.naming.cosmosdb_account.name}-${random_string.this.result}-serviceconnection" # var.pe_connection_name
#       # subnet_id                       = try(local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.subnet_name].resource.id, null)
#       subnet_id                       = try(local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.subnet_name].resource.id, null) != null ? local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.subnet_name].resource.id : var.subnet_id 

#       location                        = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location 
#       resource_group_name              = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name 
#       # below attribute not used
#       # subnet_name                     = null # "CosmosDbSubnet" 
#       # vnet_name                       = null # try(local.remote.networking.virtual_networks.spoke_project.virtual_network.name, null) != null ? local.remote.networking.virtual_networks.spoke_project.virtual_network.name : var.vnet_name  
#       # vnet_rg_name                    = null # try(local.remote.resource_group.name, null) != null ? local.remote.resource_group.name : var.vnet_resource_group_name  
#     }
#   }

#   # # tags is from local variable in the modules. to fix this - fixed on 13 Jun 2024.
#   tags        = merge(
#     local.global_settings.tags,
#     {
#       purpose = "consmos db" 
#       project_code = try(local.global_settings.prefix, var.prefix) 
#       env = try(local.global_settings.environment, var.environment) 
#       zone = "project"
#       tier = "db"   
#     }
#   ) 
  
#   depends_on = [
#     azurerm_resource_group.this,
#     module.private_dns_zones
#   ]
# }
