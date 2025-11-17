locals {
  project_id_guid       = "${substr(azapi_resource.ai_foundry_project.output.properties.internalId, 0, 8)}-${substr(azapi_resource.ai_foundry_project.output.properties.internalId, 8, 4)}-${substr(azapi_resource.ai_foundry_project.output.properties.internalId, 12, 4)}-${substr(azapi_resource.ai_foundry_project.output.properties.internalId, 16, 4)}-${substr(azapi_resource.ai_foundry_project.output.properties.internalId, 20, 12)}"
  data = {
    resource_group_name = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
    location            = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location
  }
  aifoundry_name = replace("${module.naming.cognitive_account.name}aiagent${random_string.this.result}", "-", "") 

}

# Locals for Azure IP Addresses
locals {
  cosmosdb_azure_datacenter_ip = ["0.0.0.0"]                                                         # Accept connections from within public Azure datacenters. https://learn.microsoft.com/en-us/azure/cosmos-db/how-to-configure-firewall#allow-requests-from-the-azure-portal
  cosmosdb_azure_portal_ips    = ["13.91.105.215", "4.210.172.107", "13.88.56.148", "40.91.218.243"] # Allow access from the Azure portal. https://learn.microsoft.com/en-us/azure/cosmos-db/how-to-configure-firewall#allow-requests-from-global-azure-datacenters-or-other-sources-within-azure
  aisearch_portal_ip           = "52.139.243.237"                                                    # This is obtained via nslookup as per the following documentation: https://learn.microsoft.com/en-gb/azure/search/service-configure-firewall#allow-access-from-your-client-and-portal-ip
}

# read current level terraform state - storage account
data "terraform_remote_state" "storageaccount" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.resource_group_name
    storage_account_name = var.storage_account_name
    container_name       = "2-solution-accelerators"
    key                  = "solution-accelerators-project-storageaccount.tfstate" 
  }
}

locals {
  storageaccount = {
    resource = try(data.terraform_remote_state.storageaccount.outputs.resource, null)    
    privatednszone = try(data.terraform_remote_state.storageaccount.outputs.private_dns_zone, null) 
  }
}


# get my machine public IP
provider "http" {}

data "http" "my_ip" {
  url = "https://api.ipify.org"
}

locals {
  my_public_ip = "${chomp(data.http.my_ip.response_body)}"
  ip_allowlist = concat(
    var.ingress_client_ip,
    var.deployment_machine_ips,
    [local.my_public_ip]
  )
}

output "my_ip" {
  value = local.my_public_ip
}
