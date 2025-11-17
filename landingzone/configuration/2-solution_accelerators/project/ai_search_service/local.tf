locals {
  # search service shared private link resources
  base_shared_private_links = [
    {
      groupId               = "blob"
      status                = "Approved"
      provisioningState     = "Succeeded"
      requestMessage        = "created using the Terraform template"
      privateLinkResourceId = module.avm_res_storage_storageaccount.resource.id # lookup(module.ai_foundry_core[0], "ml_storage_id", null)
    },
    {
      groupId               = "cognitiveservices_account"
      status                = "Approved"
      provisioningState     = "Succeeded"
      requestMessage        = "created using the Terraform template"
      privateLinkResourceId = module.aiservices.resource.id # azurerm_aiservices.this.id # lookup(module.ai_foundry_services[0], "aiServicesId", null)
    }
  ]

}
