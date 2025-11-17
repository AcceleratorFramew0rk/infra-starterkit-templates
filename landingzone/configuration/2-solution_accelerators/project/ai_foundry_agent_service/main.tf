## Create the AI Foundry resource
##
resource "azapi_resource" "ai_foundry" {
  depends_on = [
    azapi_resource_action.purge_ai_foundry 
  ]

  type                      = "Microsoft.CognitiveServices/accounts@2025-06-01"
  name                      = replace("${module.naming.cognitive_account.name}aiagent${random_string.this.result}", "-", "") 
  # parent_id                 = try(local.remote.resource_group.id, null) == null ? azurerm_resource_group.this.0.id : local.remote.resource_group.id
  parent_id                 = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.id : "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${local.global_settings.resource_group_name}"
  location                  = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location
  schema_validation_enabled = false

  body = {
    kind = "AIServices",
    sku = {
      name = "S0"
    }
    identity = {
      type = "SystemAssigned"
    }

    properties = {

      # # TODO: Review the disableLocalAuth setting
      # # Azure Advisor recommendation: Cognitive Services accounts should set disableLocalAuth to true to disable API key access
      # # Key access (local authentication) is recommended to be disabled for security. Azure OpenAI Studio, typically used in development/testing, requires key access and will not function if key access is disabled. After disabling, Microsoft Entra ID becomes the only access method, which allows maintaining minimum privilege principle and granular control.
      # # Learn more at: https://aka.ms/AI/auth
      # disableLocalAuth = true

      # Support both Entra ID and API Key authentication for underlining Cognitive Services account
      disableLocalAuth = false

      # Specifies that this is an AI Foundry resource
      allowProjectManagement = true

      # Set custom subdomain name for DNS names created for this Foundry resource
      customSubDomainName = replace("${module.naming.cognitive_account.name}aiagent${random_string.this.result}", "-", "")  

      # Network-related controls
      # Disable public access but allow Trusted Azure Services exception
      # To allow SEED Machine to access AI Foundry
      publicNetworkAccess = "Enabled" # publicNetworkAccess = "Enabled"   
      networkAcls = {
        defaultAction = "Deny" # "Allow"
        bypass = "AzureServices"
        ipRules = [
          for ip in concat(var.deployment_machine_ips, var.ingress_client_ip, [local.my_public_ip]) : {
            value = ip
          }
        ]        
      }

      # Enable VNet injection for Standard Agents
      networkInjections = [
        {
          scenario                   = "agent"
          subnetArmId                = azurerm_subnet.subnet_agent.id # try(local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.subnet_name].resource.id, null) != null ? local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.subnet_name].resource.id : var.subnet_id 
          useMicrosoftManagedNetwork = false
        }
      ]
    }
  }
}

## Create a deployment for OpenAI's GPT-4o in the AI Foundry resource
##
# south east asia will failed for gpt-4o
# Support gpt-4.1
# Request more quota
# Quota increase requests can be submitted via the quota increase request form. Due to high demand, quota increase requests are being accepted and will be filled in the order they're received. Priority is given to customers who generate traffic that consumes the existing quota allocation, and your request might be denied if this condition isn't met.
# https://aka.ms/oai/stuquotarequest
resource "azurerm_cognitive_deployment" "aifoundry_deployment_gpt_4o" {
  depends_on = [
    azapi_resource.ai_foundry
  ]

  name                 = "gpt-4-1"
  cognitive_account_id = azapi_resource.ai_foundry.id

  sku {
    name     = "GlobalStandard"
    capacity = 1
  }

  # The gpt 4.1 is supported in southeastasia
  # azureml://registries/azure-openai/models/gpt-4.1/versions/2025-04-14
  model {
    format  = "OpenAI"
    name    = "gpt-4.1"
    version = "2025-04-14"
  }  
  # model {
  #   format  = "OpenAI"
  #   name    = "gpt-4o"
  #   version = "2024-11-20"
  # }
}

########## Create Private DNS Zones, Links, and Private Endpoints
##########

resource "azurerm_private_dns_zone" "plz_cognitive_services" {
  name                = "privatelink.cognitiveservices.azure.com"
  resource_group_name = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
}

resource "azurerm_private_dns_zone" "plz_ai_services" {
  name                = "privatelink.services.ai.azure.com"
  resource_group_name = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
}

resource "azurerm_private_dns_zone" "plz_openai" {
  name                = "privatelink.openai.azure.com"
  resource_group_name = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
}

# ## Create Private DNS Zone Links to link the Private DNS Zones to the virtual network
# ##

resource "azurerm_private_dns_zone_virtual_network_link" "plz_cognitive_services_link" {
  depends_on = [
    azurerm_private_dns_zone.plz_cognitive_services
  ]
  name                  = "cogsvc-${random_string.this.result}-link"
  resource_group_name   = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.plz_cognitive_services.name
  virtual_network_id    = try(local.remote.networking.virtual_networks.spoke_project.virtual_network.id, null) != null ? local.remote.networking.virtual_networks.spoke_project.virtual_network.id : var.vnet_id  
  registration_enabled  = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "plz_ai_services_link" {
  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.plz_cognitive_services_link,
    azurerm_private_dns_zone.plz_ai_services
  ]
  name                  = "aiservices-${random_string.this.result}-link"
  resource_group_name   = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.plz_ai_services.name
  virtual_network_id    = try(local.remote.networking.virtual_networks.spoke_project.virtual_network.id, null) != null ? local.remote.networking.virtual_networks.spoke_project.virtual_network.id : var.vnet_id  
  registration_enabled  = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "plz_openai_link" {
  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.plz_ai_services_link,
    azurerm_private_dns_zone.plz_openai
  ]
  name                  = "openai-${random_string.this.result}-link"
  resource_group_name   = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.plz_openai.name
  virtual_network_id    = try(local.remote.networking.virtual_networks.spoke_project.virtual_network.id, null) != null ? local.remote.networking.virtual_networks.spoke_project.virtual_network.id : var.vnet_id  
  registration_enabled  = false
}

## Create Private Endpoints for resources
##

resource "azurerm_private_endpoint" "pe_aifoundry" {
  depends_on = [
    azapi_resource.ai_foundry,
    time_sleep.wait_ai_foundry_project_private_endpoint
  ]

  name                = "${azapi_resource.ai_foundry.name}-private-endpoint"
  location            = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location
  resource_group_name = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  subnet_id           = try(local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.private_endpoint_subnet_name].resource.id, null) != null ? local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.private_endpoint_subnet_name].resource.id : var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${azapi_resource.ai_foundry.name}-private-link-service-connection"
    private_connection_resource_id = azapi_resource.ai_foundry.id
    subresource_names = [
      "account"
    ]
    is_manual_connection = false
  }

  private_dns_zone_group {
    name = "${azapi_resource.ai_foundry.name}-dns-config"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.plz_cognitive_services.id,
      azurerm_private_dns_zone.plz_ai_services.id,
      azurerm_private_dns_zone.plz_openai.id
    ]
  }
}

########## Create the AI Foundry project, project connections, role assignments, and project-level capability host
##########

## Create AI Foundry project
##
resource "azapi_resource" "ai_foundry_project" {
  depends_on = [
    azapi_resource.ai_foundry,
    azurerm_private_endpoint.pe_aifoundry,
    time_sleep.wait_ai_foundry_project_private_endpoint
  ]

  type                      = "Microsoft.CognitiveServices/accounts/projects@2025-06-01"
  name                      = replace("${module.naming.cognitive_account.name}project${random_string.this.result}", "-", "") 
  parent_id                 = azapi_resource.ai_foundry.id
  location                  = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location
  schema_validation_enabled = false

  body = {
    sku = {
      name = "S0"
    }
    identity = {
      type = "SystemAssigned"
    }

    properties = {
      displayName = "project"
      description = "A project for the AI Foundry account with network secured deployed Agent"
    }
  }

  response_export_values = [
    "identity.principalId",
    "properties.internalId"
  ]
}

## Wait 10 seconds for the AI Foundry project system-assigned managed identity to be created and to replicate
## through Entra ID
resource "time_sleep" "wait_project_identities" {
  depends_on = [
    azapi_resource.ai_foundry_project
  ]
  create_duration = "10s"
}

resource "time_sleep" "wait_ai_foundry_project_private_endpoint" {
  depends_on = [
    azapi_resource.ai_foundry
  ]
  create_duration = "60s"
}

## Create AI Foundry project connections
##
resource "azapi_resource" "conn_cosmosdb" {
  type                      = "Microsoft.CognitiveServices/accounts/projects/connections@2025-06-01"
  name                      = module.cosmosdb.name
  parent_id                 = azapi_resource.ai_foundry_project.id
  schema_validation_enabled = false

  depends_on = [
    azapi_resource.ai_foundry_project
  ]

  body = {
    name = module.cosmosdb.name
    properties = {
      category = "CosmosDb"
      target   = module.cosmosdb.endpoint
      authType = "AAD"
      metadata = {
        ApiType    = "Azure"
        ResourceId = module.cosmosdb.resource_id
        location   = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location
      }
    }
  }
}

## Create the AI Foundry project connection to Azure Storage Account
##
resource "azapi_resource" "conn_storage" {
  type                      = "Microsoft.CognitiveServices/accounts/projects/connections@2025-06-01"
  name                      = module.storage_account.name 
  parent_id                 = azapi_resource.ai_foundry_project.id
  schema_validation_enabled = false

  depends_on = [
    azapi_resource.ai_foundry_project
  ]

  body = {
    name = module.storage_account.name  
    properties = {
      category = "AzureStorageAccount"
      target   = module.storage_account.resource.primary_blob_endpoint
      authType = "AAD"
      metadata = {
        ApiType    = "Azure"
        ResourceId = module.storage_account.resource_id
        location   = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location
      }
    }
  }

  response_export_values = [
    "identity.principalId"
  ]
}

## Create the AI Foundry project connection to AI Search
##
resource "azapi_resource" "conn_aisearch" {
  type                      = "Microsoft.CognitiveServices/accounts/projects/connections@2025-06-01"
  name                      = module.ai_search.resource.name
  parent_id                 = azapi_resource.ai_foundry_project.id
  schema_validation_enabled = false

  depends_on = [
    azapi_resource.ai_foundry_project
  ]

  body = {
    name = module.ai_search.resource.name
    properties = {
      category = "CognitiveSearch"
      target   = "https://${module.ai_search.resource.name}.search.windows.net"
      authType = "AAD"
      metadata = {
        ApiType    = "Azure"
        ApiVersion = "2025-05-01-preview"
        ResourceId = module.ai_search.resource_id
        location   = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location
      }
    }
  }

  response_export_values = [
    "identity.principalId"
  ]
}

## Create the necessary role assignments for the AI Foundry project over the resources used to store agent data
##
resource "azurerm_role_assignment" "cosmosdb_operator_ai_foundry_project" {
  depends_on = [
    resource.time_sleep.wait_project_identities
  ]
  name                 = uuidv5("dns", "${azapi_resource.ai_foundry_project.name}${azapi_resource.ai_foundry_project.output.identity.principalId}${try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name}cosmosdboperator")
  scope                = module.cosmosdb.resource_id
  role_definition_name = "Cosmos DB Operator"
  principal_id         = azapi_resource.ai_foundry_project.output.identity.principalId
}

resource "azurerm_role_assignment" "storage_blob_data_contributor_ai_foundry_project" {
  depends_on = [
    resource.time_sleep.wait_project_identities
  ]
  name                 = uuidv5("dns", "${azapi_resource.ai_foundry_project.name}${azapi_resource.ai_foundry_project.output.identity.principalId}${module.storage_account.name}storageblobdatacontributor")
  scope                = module.storage_account.resource_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azapi_resource.ai_foundry_project.output.identity.principalId
}

resource "azurerm_role_assignment" "search_index_data_contributor_ai_foundry_project" {
  depends_on = [
    resource.time_sleep.wait_project_identities
  ]
  name                 = uuidv5("dns", "${azapi_resource.ai_foundry_project.name}${azapi_resource.ai_foundry_project.output.identity.principalId}${module.ai_search.resource.name}searchindexdatacontributor")
  scope                = module.ai_search.resource_id
  role_definition_name = "Search Index Data Contributor"
  principal_id         = azapi_resource.ai_foundry_project.output.identity.principalId
}

resource "azurerm_role_assignment" "search_service_contributor_ai_foundry_project" {
  depends_on = [
    resource.time_sleep.wait_project_identities
  ]
  name                 = uuidv5("dns", "${azapi_resource.ai_foundry_project.name}${azapi_resource.ai_foundry_project.output.identity.principalId}${module.ai_search.resource.name}searchservicecontributor")
  scope                = module.ai_search.resource_id
  role_definition_name = "Search Service Contributor"
  principal_id         = azapi_resource.ai_foundry_project.output.identity.principalId
}

## Pause 60 seconds to allow for role assignments to propagate
##
resource "time_sleep" "wait_rbac" {
  depends_on = [
    azurerm_role_assignment.cosmosdb_operator_ai_foundry_project,
    azurerm_role_assignment.storage_blob_data_contributor_ai_foundry_project,
    azurerm_role_assignment.search_index_data_contributor_ai_foundry_project,
    azurerm_role_assignment.search_service_contributor_ai_foundry_project
  ]
  create_duration = "60s"
}

## Create the AI Foundry project capability host
##
resource "azapi_resource" "ai_foundry_project_capability_host" {
  depends_on = [
    azapi_resource.conn_aisearch,
    azapi_resource.conn_cosmosdb,
    azapi_resource.conn_storage,
    time_sleep.wait_rbac
  ]
  type                      = "Microsoft.CognitiveServices/accounts/projects/capabilityHosts@2025-04-01-preview"
  name                      = "caphostproj"
  parent_id                 = azapi_resource.ai_foundry_project.id
  schema_validation_enabled = false

  body = {
    properties = {
      capabilityHostKind = "Agents"
      vectorStoreConnections = [
        module.ai_search.resource.name
      ]
      storageConnections = [
        module.storage_account.name
      ]
      threadStorageConnections = [
        module.cosmosdb.name
      ]
    }
  }
}

## Create the necessary data plane role assignments to the CosmosDb databases created by the AI Foundry Project
##
resource "azurerm_cosmosdb_sql_role_assignment" "cosmosdb_db_sql_role_aifp_user_thread_message_store" {
  depends_on = [
    azapi_resource.ai_foundry_project_capability_host
  ]
  name                = uuidv5("dns", "${azapi_resource.ai_foundry_project.name}${azapi_resource.ai_foundry_project.output.identity.principalId}userthreadmessage_dbsqlrole")
  resource_group_name = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  account_name        = module.cosmosdb.name
  scope               = "${module.cosmosdb.resource_id}/dbs/enterprise_memory/colls/${local.project_id_guid}-thread-message-store"
  role_definition_id  = "${module.cosmosdb.resource_id}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002"
  principal_id        = azapi_resource.ai_foundry_project.output.identity.principalId
}

resource "azurerm_cosmosdb_sql_role_assignment" "cosmosdb_db_sql_role_aifp_system_thread_name" {
  depends_on = [
    azurerm_cosmosdb_sql_role_assignment.cosmosdb_db_sql_role_aifp_user_thread_message_store
  ]
  name                = uuidv5("dns", "${azapi_resource.ai_foundry_project.name}${azapi_resource.ai_foundry_project.output.identity.principalId}systemthread_dbsqlrole")
  resource_group_name = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  account_name        = module.cosmosdb.name
  scope               = "${module.cosmosdb.resource_id}/dbs/enterprise_memory/colls/${local.project_id_guid}-system-thread-message-store"
  role_definition_id  = "${module.cosmosdb.resource_id}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002"
  principal_id        = azapi_resource.ai_foundry_project.output.identity.principalId
}

resource "azurerm_cosmosdb_sql_role_assignment" "cosmosdb_db_sql_role_aifp_entity_store_name" {
  depends_on = [
    azurerm_cosmosdb_sql_role_assignment.cosmosdb_db_sql_role_aifp_system_thread_name
  ]
  name                = uuidv5("dns", "${azapi_resource.ai_foundry_project.name}${azapi_resource.ai_foundry_project.output.identity.principalId}entitystore_dbsqlrole")
  resource_group_name = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  account_name        = module.cosmosdb.name
  scope               = "${module.cosmosdb.resource_id}/dbs/enterprise_memory/colls/${local.project_id_guid}-agent-entity-store"
  role_definition_id  = "${module.cosmosdb.resource_id}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002"
  principal_id        = azapi_resource.ai_foundry_project.output.identity.principalId
}

## Create the necessary data plane role assignments to the Azure Storage Account containers created by the AI Foundry Project
##
resource "azurerm_role_assignment" "storage_blob_data_owner_ai_foundry_project" {
  depends_on = [
    azapi_resource.ai_foundry_project_capability_host
  ]
  name                 = uuidv5("dns", "${azapi_resource.ai_foundry_project.name}${azapi_resource.ai_foundry_project.output.identity.principalId}${module.storage_account.name}storageblobdataowner")
  scope                = module.storage_account.resource_id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azapi_resource.ai_foundry_project.output.identity.principalId
  condition_version    = "2.0"
  condition            = <<-EOT
  (
    (
      !(ActionMatches{'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/tags/read'})
      AND !(ActionMatches{'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/filter/action'})
      AND !(ActionMatches{'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/tags/write'})
    )
    OR
    (@Resource[Microsoft.Storage/storageAccounts/blobServices/containers:name] StringStartsWithIgnoreCase '${local.project_id_guid}'
    AND @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:name] StringLikeIgnoreCase '*-azureml-agent')
  )
  EOT
}

## Added AI Foundry account purger to avoid running into InUseSubnetCannotBeDeleted-lock caused by the agent subnet delegation.
## The azapi_resource_action.purge_ai_foundry (only gets executed during destroy) purges the AI foundry account removing /subnets/snet-agent/serviceAssociationLinks/legionservicelink so the agent subnet can get properly removed.

resource "azapi_resource_action" "purge_ai_foundry" {
  method      = "DELETE"
  # ORI # resource_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.CognitiveServices/locations/${local.data.location}/resourceGroups/${local.aifoundry_name}"
  resource_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.CognitiveServices/locations/${local.data.location}/resourceGroups/${local.data.resource_group_name}/deletedAccounts/${local.aifoundry_name}"
  # resource_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.CognitiveServices/locations/${local.data.location}/resourceGroups/${local.data.resource_group_name}/deletedAccounts/aifoundry${random_string.this.result}"
  type        = "Microsoft.Resources/resourceGroups/deletedAccounts@2021-04-30"
  when        = "destroy"

  depends_on = [time_sleep.purge_ai_foundry_cooldown]
}

resource "time_sleep" "purge_ai_foundry_cooldown" {
  destroy_duration = "900s" # 10-15m is enough time to let the backend remove the /subnets/snet-agent/serviceAssociationLinks/legionservicelink

  depends_on = [module.storage_account]
}
