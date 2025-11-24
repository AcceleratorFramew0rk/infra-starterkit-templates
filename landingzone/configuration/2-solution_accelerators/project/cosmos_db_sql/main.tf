module "private_dns_zones" {
  source                = "Azure/avm-res-network-privatednszone/azurerm"   
  # version = "0.1.2" 
  version = "0.3.3"

  enable_telemetry      = true
  resource_group_name   = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  domain_name           = "privatelink.documents.azure.com"

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
  name                = "${module.naming.cosmosdb_account.name}-sql-${random_string.this.result}" # module.naming.container_group.name_unique

  analytical_storage_enabled = true
  
  diagnostic_settings = {
    log1 = {
      workspace_resource_id    = try(local.remote.log_analytics_workspace.id, null) != null ? local.remote.log_analytics_workspace.id : var.log_analytics_workspace_id 
    }
  }

  private_endpoints = {
    primary = {
      name                            = "${module.naming.cosmosdb_account.name}-${random_string.this.result}-sql-pep"
      private_dns_zone_resource_ids = [module.private_dns_zones.resource.id] 
      subnet_resource_id            = try(local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.subnet_name].resource.id, null) != null ? local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.subnet_name].resource.id : var.subnet_id 
      subresource_name              = "SQL"
      public_network_access_enabled           = false
      private_endpoints_manage_dns_zone_group = false     
      private_service_connection_name = "primary_sql_connection" 
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

  geo_locations = [ #Sql Gateway in a region with zone redundant enabled require a support ticket to allow it
    {
      failover_priority = 0
      zone_redundant    = false
      location          = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location # "southeastasia"
    }
  ]

  sql_dedicated_gateway = {
    instance_count = var.instance_count # 1
    instance_size  = var.instance_size # "Cosmos.D4s"
  }

  sql_databases = {
    empty_database = {
      name = "empty_database"

      containers = {
        empty_container = {
          name                = "empty_container"
          partition_key_paths = ["/id"]
        }
      }
    }

    database_fixed_througput = {
      name       = "database_fixed_througput"
      throughput = var.throughout # 400
    }

    database_autoscale_througput = {
      name = "database_autoscale_througput"

      autoscale_settings = {
        max_throughput = var.max_throughput # 4000
      }
    }

    database_and_container_fixed_througput = {
      name       = "database_and_container_fixed_througput"
      throughput = var.throughout # 400

      containers = {
        container_fixed_througput = {
          name                = "container_fixed_througput"
          partition_key_paths = ["/id"]
          throughput          = var.throughout # 400
        }
      }
    }

    database_and_container_autoscale_througput = {
      name = "database_and_container_autoscale_througput"

      autoscale_settings = {
        max_throughput = var.max_throughput # 4000
      }

      containers = {
        container_fixed_througput = {
          name                = "container_fixed_througput"
          partition_key_paths = ["/id"]

          autoscale_settings = {
            max_throughput = var.max_throughput # 4000
          }
        }
      }
    }

    database_containers_tests = {
      name = "database_containers_tests"

      containers = {
        container_fixed_througput = {
          name                = "container_fixed_througput"
          partition_key_paths = ["/id"]
          throughput          = 400
        }

        container_autoscale_througput = {
          name                = "container_autoscale_througput"
          partition_key_paths = ["/id"]

          autoscale_settings = {
            max_throughput = 4000
          }
        }

        container_infinite_analytical_ttl = {
          name                   = "container_infinite_analytical_ttl"
          partition_key_paths    = ["/id"]
          analytical_storage_ttl = -1
        }

        container_fixed_analytical_ttl = {
          name                   = "container_fixed_analytical_ttl"
          partition_key_paths    = ["/id"]
          analytical_storage_ttl = 1000
        }

        container_document_ttl = {
          name                = "container_document_ttl"
          partition_key_paths = ["/id"]
          default_ttl         = 1000
        }

        container_unique_keys = {
          name                = "container_unique_keys"
          partition_key_paths = ["/id"]

          unique_keys = [
            {
              paths = ["/field1", "/field2"]
            }
          ]
        }

        container_conflict_resolution_with_path = {
          name                = "container_conflict_resolution_with_path"
          partition_key_paths = ["/id"]

          conflict_resolution_policy = {
            mode                     = "LastWriterWins"
            conflict_resolution_path = "/customProperty"
          }
        }

        container_conflict_resolution_with_stored_procedure = {
          name                = "container_conflict_resolution_with_stored_procedure"
          partition_key_paths = ["/id"]

          conflict_resolution_policy = {
            mode                          = "Custom"
            conflict_resolution_procedure = "resolver"
          }

          stored_procedures = {
            resolver = {
              name = "resolver"
              body = "function resolver(incomingItem, existingItem, isTombstone, conflictingItems) { }"
            }
          }
        }

        container_with_functions = {
          name                = "container_with_functions"
          partition_key_paths = ["/id"]

          functions = {
            empty = {
              name = "empty"
              body = "function empty() { return; }"
            }
          }
        }

        container_with_stored_procedures = {
          name                = "container_with_stored_procedures"
          partition_key_paths = ["/id"]

          stored_procedures = {
            empty = {
              name = "empty"
              body = <<BODY
                function empty() { }
              BODY
            }
          }
        }

        container_with_triggers = {
          name                = "container_with_triggers"
          partition_key_paths = ["/id"]

          triggers = {
            testTrigger = {
              name      = "testTrigger"
              body      = "function testTrigger(){}"
              operation = "Delete"
              type      = "Post"
            }
          }
        }

        container_with_none_index_policy = {
          name                = "container_with_none_index_policy"
          partition_key_paths = ["/id"]

          indexing_policy = {
            indexing_mode = "none"
          }
        }

        container_with_consistent_index_policy = {
          name                = "container_with_consistent_index_policy"
          partition_key_paths = ["/id"]

          indexing_policy = {
            indexing_mode = "consistent"

            included_paths = [
              {
                path = "/hola/?"
              }
            ]
            excluded_paths = [
              {
                path = "/*"
              }
            ]
            spatial_indexes = [
              {
                path = "/field2/?"
              }
            ]
            composite_indexes = [
              {
                indexes = [
                  {
                    path  = "/field3"
                    order = "Ascending"
                  },
                  {
                    path  = "/field4"
                    order = "Descending"
                  }
                ]
              }
            ]
          }
        }
      }
    }
  }

  depends_on = [
    module.private_dns_zones
  ]

}
