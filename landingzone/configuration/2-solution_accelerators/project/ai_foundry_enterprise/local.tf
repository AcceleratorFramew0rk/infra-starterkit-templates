
# # read current level terraform state - storage_account_private_dns_zone
data "terraform_remote_state" "storage_account_private_dns_zone" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.resource_group_name
    storage_account_name = var.storage_account_name
    container_name       = "2-solution-accelerators"
    key                  = "solution-accelerators-project-storageaccount.tfstate" 
  }
}

locals {
  storage_account_private_dns_zone = try(data.terraform_remote_state.storage_account_private_dns_zone.outputs.private_dns_zone, null)     
}


locals {
  tags = {
    scenario = "Private AI Foundry Hub"
  }
  name                         = "${module.naming.cognitive_account.name}-aihub-${random_string.this.result}" # alpha numeric characters only are allowed in "name var.name_prefix == null ? "${random_string.prefix.result}${var.acr_name}" : "${var.name_prefix}${var.acr_name}"
  base_name                    = "${module.naming.cognitive_account.name}" # alpha numeric characters only are allowed in "name var.name_prefix == null ? "${random_string.prefix.result}${var.acr_name}" : "${var.name_prefix}${var.acr_name}"

}

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

  # ai hub outbound rules
  base_ai_hub_outbound_rules = {
    # search = {
    #   type = "PrivateEndpoint"
    #   destination = {
    #     serviceResourceId = module.aisearch.resource.id # lookup(module.ai_foundry_services[0], "search_service_id", null)
    #     subresourceTarget = "searchService"
    #     sparkEnabled      = false
    #     sparkStatus       = "Inactive"
    #   }
    # }
    aiservices = {
      type = "PrivateEndpoint"
      destination = {
        serviceResourceId = module.aiservices.resource.id # azurerm_aiservices.this.id # lookup(module.ai_foundry_services[0], "aiServicesId", null)
        subresourceTarget = "account"
        sparkEnabled      = false
        sparkStatus       = "Inactive"
      }
    }
  }
}

# get my machine public IP
provider "http" {}

data "http" "my_ip" {
  url = "https://api.ipify.org"
}

locals {
  my_public_ip = "${chomp(data.http.my_ip.response_body)}/32"
}

output "my_ip" {
  value = local.my_public_ip
}