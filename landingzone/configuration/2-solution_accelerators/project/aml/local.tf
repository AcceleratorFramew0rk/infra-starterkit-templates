
locals {
  name                         = "${module.naming.cognitive_account.name}-azureml-${random_string.this.result}" 
  base_name                    = "${module.naming.cognitive_account.name}" 
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

locals {
  tags = {
    scenario = "AML with Diagnostic Settings"
  }
}

# Locals for Azure IP Addresses
locals {
  cosmosdb_azure_datacenter_ip = ["0.0.0.0"]                                                         # Accept connections from within public Azure datacenters. https://learn.microsoft.com/en-us/azure/cosmos-db/how-to-configure-firewall#allow-requests-from-the-azure-portal
  cosmosdb_azure_portal_ips    = ["13.91.105.215", "4.210.172.107", "13.88.56.148", "40.91.218.243"] # Allow access from the Azure portal. https://learn.microsoft.com/en-us/azure/cosmos-db/how-to-configure-firewall#allow-requests-from-global-azure-datacenters-or-other-sources-within-azure
  aisearch_portal_ip           = "52.139.243.237"                                                    # This is obtained via nslookup as per the following documentation: https://learn.microsoft.com/en-gb/azure/search/service-configure-firewall#allow-access-from-your-client-and-portal-ip
}