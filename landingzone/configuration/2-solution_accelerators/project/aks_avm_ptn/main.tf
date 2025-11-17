module "private_dns_zones" {
  source                = "Azure/avm-res-network-privatednszone/azurerm"   
  version = "0.3.0"

  enable_telemetry      = true
  resource_group_name   = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  domain_name           = "privatelink.azurecr.io"
  tags         = merge(
    local.global_settings.tags,
    {
      purpose = "container registry dns zone" 
      project_code = try(local.global_settings.prefix, var.prefix) 
      env = try(local.global_settings.environment, var.environment) 
      zone = "project"
      tier = "service"   
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
            purpose = "container registry vnet link" 
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
            purpose = "container registry vnet link" 
            project_code = try(local.global_settings.prefix, var.prefix) 
            env = try(local.global_settings.environment, var.environment) 
            zone = "project"
            tier = "service"   
          }
        )
      }      
    }
}

resource "azurerm_user_assigned_identity" "this" {
  location                     = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location
  name                = "uami-${lower(module.naming.kubernetes_cluster.name)}" 
  resource_group_name       = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name # local.resource_group.name

}

# assign network contributor to gcci_platform project vnet id
resource "azurerm_role_assignment" "network_contributor_assignment" {
  scope                = local.remote.networking.virtual_networks.spoke_project.virtual_network.id # project vnet id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.this.principal_id  
  skip_service_principal_aad_check = true

  depends_on = [
    module.aks_cluster
  ]
}

# assign reader to gcci_platform project vnet id
resource "azurerm_role_assignment" "reader_assignment" {
  scope                = local.remote.networking.virtual_networks.spoke_project.virtual_network.id # project vnet id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.this.principal_id 
  skip_service_principal_aad_check = true

  depends_on = [
    module.aks_cluster
  ]
}

# Azure Kubernetes Service Cluster Admin Role - List cluster admin credential action.
# Azure Kubernetes Service RBAC Admin - Lets you manage all resources under cluster/namespace, except update or delete 
# Azure Kubernetes Service Contributor Role - Grants access to read and write Azure Kubernetes Service clusters
resource "azurerm_role_assignment" "Azure_Kubernetes_Service_Cluster_Admin_Role" {
  scope                = module.aks_cluster.resource_id # resource.id
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
  principal_id         = data.azurerm_client_config.current.object_id # principal_id  
  # skip_service_principal_aad_check = true

  depends_on = [
    module.aks_cluster
  ]
}

resource "azurerm_role_assignment" "Azure_Kubernetes_Service_RBAC_Admin" {
  scope                = module.aks_cluster.resource_id # resource.id
  role_definition_name = "Azure Kubernetes Service RBAC Admin"
  principal_id         = data.azurerm_client_config.current.object_id # principal_id  # data.azurerm_client_config.current.object_id
  # skip_service_principal_aad_check = true

  depends_on = [
    module.aks_cluster
  ]
}

resource "azurerm_role_assignment" "Azure_Kubernetes_Service_Contributor_Role" {
  scope                = module.aks_cluster.resource_id # resource.id
  role_definition_name = "Azure Kubernetes Service Contributor Role"
  principal_id         = data.azurerm_client_config.current.object_id # principal_id  
  # skip_service_principal_aad_check = true

  depends_on = [
    module.aks_cluster
  ]
}



# This is the module call
# Do not specify location here due to the randomization above.
# Leaving location as `null` will cause the module to use the resource group location
# with a data source.
module "aks_cluster" {
  # source = "./../../../../../../modules/terraform-azurerm-aaf/modules/compute/terraform-azurerm-avm-ptn-aks-production"  
  source = "AcceleratorFramew0rk/aaf/azurerm//modules/compute/terraform-azurerm-avm-ptn-aks-production" 
  version = "0.0.21"
  # # version = "0.0.17"
  # # version = "0.0.8"

  # source  = "Azure/avm-ptn-aks-production/azurerm" # not full feature yet - TBC
  # version = "0.5.0"
  

  kubernetes_version  = var.kubernetes_version # "1.31" # "1.30"
  enable_telemetry    = var.enable_telemetry # see variables.tf
  name                = "${module.naming.kubernetes_cluster.name}-private-cluster"  
  resource_group_name       = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name

  rbac_aad_tenant_id = data.azurerm_client_config.current.tenant_id # tenant_id from client config
  default_node_pool_vm_sku = var.vm_size # "Standard_D4_v3" # "Standard_D2d_v5"

  network = {
    name = "gcci-vnet-project"  # variable not used in module
    resource_group_name       = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name  # variable not used in module
 
    node_subnet_id      = try(local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.systemnode_subnet_name].resource.id, null) != null ? local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.systemnode_subnet_name].resource.id : var.systemnode_subnet_id
    pod_cidr            = "172.31.0.0/18"
    dns_service_ip      = "172.16.0.10" # "10.0.0.10"
    service_cidr        = "172.16.0.0/18" #"10.0.0.0/16"
  }

  # TODO: cosmestic feature - remove this when we have a better solution
  # node_resource_group = try(local.global_settings.resource_group_name, null) != null ? "${module.naming.resource_group.name}-aks-nodes" : "${azurerm_resource_group.this.0.name}-aks-nodes"

  acr = {
    name                          = replace("${module.naming.container_registry.name}aks${random_string.this.result}", "-", "") # "${module.naming.container_registry.name_unique}${random_string.this.result}" # module.naming.container_registry.name_unique
    private_dns_zone_resource_ids = [module.private_dns_zones.resource.id] 
    subnet_resource_id            = try(local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.acr_subnet_name].resource.id, null) != null ? local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.acr_subnet_name].resource.id : var.acr_subnet_id 
  }

  managed_identities = {
    user_assigned_resource_ids = [
      azurerm_user_assigned_identity.this.id
    ]
  }

  location                     = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location

  node_pools = {
    ezwl = {
      name                 = "ezwl" # intranet (ez) workload (wl) - the "name" must begin with a lowercase letter, contain only lowercase letters and numbers and be between 1 and 12 characters in length
      vm_size              = var.vm_size # "Standard_D4_v3" # "Standard_D2d_v5"
      orchestrator_version = var.kubernetes_version # "1.31" # "1.30"
      max_count            = var.max_count # 8 # ensure subnet has sufficent IPs
      min_count            = var.min_count # 2
      os_sku               = "Ubuntu"
      mode                 = "User"
      vnet_subnet_id       = try(local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.usernode_subnet_name].resource.id, null) != null ? local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.usernode_subnet_name].resource.id : var.usernode_subnet_id
      # Setting node labels
      labels = {
        "environment" = "production"
        "agentnodepool"         = "poolappsinternet"
      }
    }
    izwl = {
      name                 = "izwl" # intranet (iz) workload (wl)- the "name" must begin with a lowercase letter, contain only lowercase letters and numbers and be between 1 and 12 characters in length
      vm_size              = "Standard_D4_v3" # "Standard_D2d_v5"
      orchestrator_version = var.kubernetes_version # "1.31" # "1.30"
      max_count            = var.max_count # 8 # ensure subnet has sufficent IPs
      min_count            = var.min_count # 2
      os_sku               = "Ubuntu"
      mode                 = "User"
      vnet_subnet_id       = try(local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.usernodeintranet_subnet_name].resource.id, null) != null ? local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.usernodeintranet_subnet_name].resource.id : var.usernodeintranet_subnet_id
      # Setting node labels
      labels = {
        "environment" = "production"
        "agentnodepool"         = "poolappsintranet"
      }
    }     

  }

  tags                = merge(
    local.global_settings.tags,
    {
      purpose = "aks private cluster" 
      project_code = try(local.global_settings.prefix, var.prefix) 
      env = try(local.global_settings.environment, var.environment) 
      zone = "project"
      tier = "nodes"   
    }
  ) 
}
