locals {
  sql_dbs     = {
    cosmosdb1 = {
      db_name           = "cosmosdb-sql-db"
      db_throughput     = var.db_throughput
      db_max_throughput = var.db_max_throughput
    }
  }

  sql_db_containers = {
    "default_container" = {
      container_name           = "default-container"
      db_name                  = "default-db"
      partition_key_path       = "/id"
      partition_key_version    = 2
      container_throughout     = var.container_throughout #  400
      container_max_throughput = var.container_max_throughput # 4000
      default_ttl              = -1
      analytical_storage_ttl   = 0
      indexing_policy_settings = {
        sql_indexing_mode = "consistent"
        sql_included_path = "/*"
        sql_excluded_path = "/\"_etag\"/?"  # ✅ Only valid paths
        composite_indexes = {}
        spatial_indexes   = {}
      }
      sql_unique_key = []
      conflict_resolution_policy = {
        mode      = "LastWriterWins"
        path      = "/_ts"
        procedure = ""
      }
    }
  }

}

