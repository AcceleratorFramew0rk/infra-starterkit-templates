# AI HUB - for_each = var.role_assignments

# ai hub storageaccount - grant storage blob data contributor role to aiservice object id
resource "azurerm_role_assignment" "ai_service_storage_blob_contributor" {
  scope                = module.avm_res_storage_storageaccount.resource_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.aiservices.resource.identity[0].principal_id

  depends_on = [
    module.avm_res_storage_storageaccount,
    module.aiservices
  ]
}

# ai hub storageaccount - grant storage blob data contributor role to search service object id
resource "azurerm_role_assignment" "search_service_storage_blob_contributor" {
  scope                = module.avm_res_storage_storageaccount.resource_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.aisearch.resource.identity[0].principal_id

  depends_on = [
    module.avm_res_storage_storageaccount,
    module.aisearch
  ]
}

# ai services - grant Cognitive Services OpenAI Contributor role to search service object id
resource "azurerm_role_assignment" "search_service_to_openai" {
  scope                = module.aiservices.resource.id
  role_definition_name = "Cognitive Services OpenAI Contributor"
  principal_id         = module.aisearch.resource.identity[0].principal_id

  depends_on = [
    module.aiservices,
    module.aisearch
  ]
}

// Role Assignments for ACR Push/Pull
resource "azurerm_role_assignment" "acr_push_role_assignment" {
  principal_id         = module.aihub.system_assigned_mi_principal_id # module.aihub.resource.identity[0].principal_id # azapi_resource.ai_hub.identity[0].principal_id
  role_definition_name = "AcrPush"
  scope                = module.avm_res_containerregistry_registry.resource.id # azurerm_container_registry.acr.id
  depends_on = [
    module.aiservices,
    module.aihub
  ]
}

resource "azurerm_role_assignment" "acr_pull_role_assignment" {
  principal_id         = module.aihub.system_assigned_mi_principal_id # module.aihub.resource.identity[0].principal_id # azapi_resource.ai_hub.identity[0].principal_id
  role_definition_name = "AcrPull"
  scope                = module.avm_res_containerregistry_registry.resource.id # azurerm_container_registry.acr.id
  depends_on = [
    module.aiservices,
    module.aihub
  ]  
}

# ai search service role assignment
resource "azurerm_role_assignment" "search_index_data_reader_role_assignment" {
  principal_id         = module.aihub.system_assigned_mi_principal_id # module.aihub.resource.identity[0].principal_id # azapi_resource.ai_hub.identity[0].principal_id
  role_definition_name = "Search Index Data Reader"
  scope                = module.aisearch.resource.id # azurerm_container_registry.acr.id
  depends_on = [
    module.aiservices,
    module.aihub
  ]  
}

resource "azurerm_role_assignment" "search_index_data_contributor_role_assignment" {
  principal_id         = module.aihub.system_assigned_mi_principal_id # module.aihub.resource.identity[0].principal_id # azapi_resource.ai_hub.identity[0].principal_id
  role_definition_name = "Search Index Data Contributor"
  scope                = module.aisearch.resource.id # azurerm_container_registry.acr.id
  depends_on = [
    module.aiservices,
    module.aihub
  ]  
}

resource "azurerm_role_assignment" "search_service_contributor_role_assignment" {
  principal_id         = module.aihub.system_assigned_mi_principal_id # module.aihub.resource.identity[0].principal_id # azapi_resource.ai_hub.identity[0].principal_id
  role_definition_name = "Search Service Contributor"
  scope                = module.aisearch.resource.id # azurerm_container_registry.acr.id
  depends_on = [
    module.aiservices,
    module.aihub
  ]  
}

resource "azurerm_role_assignment" "storage_blob_data_owner_role_assignment" {
  principal_id         = module.aihub.system_assigned_mi_principal_id # module.aihub.resource.identity[0].principal_id # azapi_resource.ai_hub.identity[0].principal_id
  role_definition_name = "Storage Blob Data Owner"
  scope                = module.avm_res_storage_storageaccount.resource.id # azurerm_container_registry.acr.id
  depends_on = [
    module.aiservices,
    module.aihub
  ]  
}


resource "azurerm_role_assignment" "storage_file_data_privileged_contributor_role_assignment" {
  principal_id         = module.aihub.system_assigned_mi_principal_id # module.aihub.resource.identity[0].principal_id # azapi_resource.ai_hub.identity[0].principal_id
  role_definition_name = "Storage File Data Privileged Contributor"
  scope                = module.aiservices.resource.id # azurerm_container_registry.acr.id
  depends_on = [
    module.aiservices,
    module.aihub
  ]  
}

# ai services
resource "azurerm_role_assignment" "cognitive_services_openai_contributor_role_assignment" {
  principal_id         = module.aihub.system_assigned_mi_principal_id # module.aihub.resource.identity[0].principal_id # azapi_resource.ai_hub.identity[0].principal_id
  role_definition_name = "Cognitive Services OpenAI Contributor"
  scope                = module.aiservices.resource.id # azurerm_container_registry.acr.id
  depends_on = [
    module.aiservices,
    module.aihub
  ]  
}

# resource group role assignment
resource "azurerm_role_assignment" "ai_inference_deployment_operator_role_assignment" {
  principal_id         = module.aihub.system_assigned_mi_principal_id # module.aihub.resource.identity[0].principal_id # azapi_resource.ai_hub.identity[0].principal_id
  role_definition_name = "Azure AI Inference Deployment Operator"
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name}"  # resource_group_id # module.aiservices.resource.id # azurerm_container_registry.acr.id
  depends_on = [
    module.aiservices,
    module.aihub
  ]  
}


resource "azurerm_role_assignment" "user_access_administrator_role_assignment" {
  principal_id         = module.aihub.system_assigned_mi_principal_id # module.aihub.resource.identity[0].principal_id # azapi_resource.ai_hub.identity[0].principal_id
  role_definition_name = "User Access Administrator"
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name}"  # resource_group_id # module.aiservices.resource.id # azurerm_container_registry.acr.id
  depends_on = [
    module.aiservices,
    module.aihub
  ]  
}

resource "azurerm_role_assignment" "Azure_AI_Enterprise_Network_Connection_Approver_role_assignment" {
  principal_id         = module.aihub.system_assigned_mi_principal_id # module.aihub.resource.identity[0].principal_id # azapi_resource.ai_hub.identity[0].principal_id
  role_definition_name = "Azure AI Enterprise Network Connection Approver"
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name}"  # resource_group_id # module.aiservices.resource.id # azurerm_container_registry.acr.id
  depends_on = [
    module.aiservices,
    module.aihub
  ]  
}
    


# variable "eligible_roles" {
#   type = map(string)
#   default = {
#     search_index_data_contributor             = "8ebe5a00-799e-43f5-93ac-243d3dce84a7"
#     search_index_data_reader                  = "1407120a-92aa-4202-b7e9-c0e197c71c8f"
#     search_service_contributor                = "7ca78c08-252a-4471-8644-bb5ff32d4ba0"
#     storage_blob_data_contributor             = "ba92f5b4-2d11-453d-a403-e96b0029c9fe"
#     storage_blob_data_privileged_contributor  = "69566ab7-960f-475b-8e7c-b3118f30c6bd"
#     storage_blob_data_owner                   = "b7e6dc6d-f1e8-4753-8033-0f276bb0955b"
#     cognitive_services_openai_contributor     = "a001fd3d-188f-4b5d-821b-7da978bf7442"
#     cognitive_services_openai_user            = "5e0bd9bd-7b93-4f28-af87-19fc36ad61bd"
#     ai_inference_deployment_operator          = "3afb7f49-54cb-416e-8c09-6dc049efa503"
#     contributor                               = "b24988ac-6180-42a0-ab88-20f7382dd24c"
#     reader                                    = "acdd72a7-3385-48ef-bd42-f606fba81ae7"
#     key_vault_administrator                   = "00482a5a-887f-4fb3-b363-3b7fe8e74483"
#     user_access_administrator                 = "18d7d88d-d35e-4fb5-a5c3-7773c20a72d9"
#     owner                                     = "8e3af657-a8ff-443c-a75c-2fe8c4bcb635"
#     storage_file_data_privileged_contributor  = "69566ab7-960f-475b-8e7c-b3118f30c6bd"
#     storage_file_data_smb_share_contributor   = "0c867c2a-1d8c-454a-a3db-ab2ea1bdc8bb"
#     azure_ai_developer                        = "64702f94-c441-49e6-a78b-ef80e0188fee"
#     azure_ai_administrator                    = "b78c5d69-af96-48a3-bf8d-a8b4d589de94"
#   }
# }

# variable "role_templates" {
#   type = map(list(object({
#     role_name      = string
#     scope = string
#   })))
#   default = {
#     infra_admin = [
#       { role_name = "contributor", scope = "resource_group_id" },
#       { role_name = "azure_ai_administrator", scope = "resource_group_id" },
#       { role_name = "search_index_data_contributor", scope = "ai_search_service_id" },
#       { role_name = "cognitive_services_openai_user", scope = "openai_embedding_id" },
#       { role_name = "cognitive_services_openai_contributor", scope = "openai_chat_id" },
#       { role_name = "search_service_contributor", scope = "ai_search_service_id" },
#       { role_name = "storage_blob_data_contributor", scope = "storage_account_id" },
#       { role_name = "storage_file_data_privileged_contributor", scope = "storage_account_id" }
#     ]
#     ai_admin = [
#       { role_name = "azure_ai_administrator", scope = "resource_group_id" },
#       { role_name = "owner", scope = "ai_hub_id" },
#       { role_name = "search_index_data_contributor", scope = "ai_search_service_id" },
#       { role_name = "search_service_contributor", scope = "ai_search_service_id" },
#       { role_name = "cognitive_services_openai_contributor", scope = "openai_chat_id" },
#       { role_name = "cognitive_services_openai_user", scope = "openai_embedding_id" },
#       { role_name = "storage_blob_data_contributor", scope = "storage_account_id" },
#       { role_name = "storage_file_data_privileged_contributor", scope = "storage_account_id" }
#     ]
#   }
# }
