resource "azurerm_container_app_environment" "this" {
  location                 = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.location : local.global_settings.location
  name                     = "${module.naming.container_app_environment.name_unique}${random_string.this.result}" # "my-environment"
  resource_group_name      = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  infrastructure_subnet_id = try(local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.subnet_name].resource.id, null) != null ? local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.subnet_name].resource.id : var.subnet_id  # azurerm_subnet.subnet.id
  internal_load_balancer_enabled = true
  logs_destination           = "log-analytics"
  log_analytics_workspace_id = local.remote.log_analytics_workspace.id 
  
  workload_profile {
    name = "profile_${var.workload_profile_type}"
    # (
    #   length(replace("${module.naming.container_app_environment.name}-${random_string.this.result}", "-", "")) > 16
    #   ? substr(replace("${module.naming.container_app_environment.name}-${random_string.this.result}", "-", ""), 0, 16)
    #   : replace("${module.naming.container_app_environment.name}-${random_string.this.result}", "-", "")
    # )
    
    # ** IMPORTANT ** workload_profile_type = "D16" # Possible values include Consumption, D4, D8, D16, D32, E4, E8, E16 and E32
    workload_profile_type = var.workload_profile_type # "D16" # Possible values include Consumption, D4, D8, D16, D32, E4, E8, E16 and E32
    maximum_count = 8 # try(var.maximum_count, 10) # - (Required) The maximum number of instances of workload profile that can be deployed in the Container App Environment.
    minimum_count = 3 # minimum is 3 for production due to redundency concern: try(var.minimum_count, 1) # - (Required) The minimum number of instances of workload profile that can be deployed in the Container App Environment.

  }

  tags = merge(
    local.global_settings.tags,
    {
      purpose = "container app environment" 
      project_code = try(local.global_settings.prefix, var.prefix) 
      env = try(local.global_settings.environment, var.environment) 
      zone = "project"
      tier = "app"   
    }
  )   
}


module "containerapp" {
  source  = "Azure/avm-res-app-containerapp/azurerm"
  # version = "0.3.0"
  # version = "0.6.0"
  version = "0.7.0"

  for_each                     = toset(var.resource_names)
  
  container_app_environment_resource_id = azurerm_container_app_environment.this.id
  name                                  = "${module.naming.container_app.name}-${each.value}-${random_string.this.result}1" # local.counting_app_name
  resource_group_name                   = try(local.global_settings.resource_group_name, null) == null ? azurerm_resource_group.this.0.name : local.global_settings.resource_group_name
  revision_mode                         = "Single"
  template = {
    containers = [
      {
        name   = "${each.value}${random_string.this.result}" # "frontend"
        memory = var.memory # "0.5Gi"
        cpu    = var.cpu # 0.25
        image  = var.frontend_image # "docker.io/hashicorp/counting-service:0.0.2"
        min_replicas = 1
        max_replicas = 10
        # env = [
        #   {
        #     name  = "PORT"
        #     value = "900${each.value}"
        #   }
        # ]
      },
    ]
  }
  ingress = {
    allow_insecure_connections = true
    external_enabled           = true
    target_port                = 9001
    traffic_weight = [{
      latest_revision = true
      percentage      = 100
    }]
  }  

  tags = merge(
    local.global_settings.tags,
    {
      purpose = "container app - ${each.value}" 
      project_code = try(local.global_settings.prefix, var.prefix) 
      env = try(local.global_settings.environment, var.environment) 
      zone = "project"
      tier = "app"   
    }
  ) 


  depends_on = [
    azurerm_container_app_environment.this
  ]

}
