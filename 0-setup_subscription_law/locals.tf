# This allow use to randomize the name of resources
locals {
  const_yaml = "yaml"
  const_yml  = "yml"
  configuration_file_path = ""
  location = "southeastasia"

  config_file_name      = local.configuration_file_path == "" ? "config.yaml" : basename(local.configuration_file_path)
  config_file_split     = split(".", local.config_file_name)
  config_file_extension = replace(lower(element(local.config_file_split, length(local.config_file_split) - 1)), local.const_yml, local.const_yaml)
}
locals {
  config_template_file_variables = {
    default_location                = local.location # var.default_location
  }

  config = (local.config_file_extension == local.const_yaml ?
    yamldecode(templatefile("./${local.config_file_name}", local.config_template_file_variables)) :
    jsondecode(templatefile("./${local.config_file_name}", local.config_template_file_variables))
  )
}

resource "random_string" "this" {
  length  = 6
  special = false
  upper   = false
}

data "azurerm_client_config" "current" {}

# local variables
locals {
  # GCC 2.0 compartment information 
  log_analytics_workspace_resource_group_name = try(local.config.log_analytics_workspace_resource_group_name, null) != null ? local.config.log_analytics_workspace_resource_group_name : var.log_analytics_workspace_resource_group_name # "gcci-agency-law"  # DO NOT CHANGE
  log_analytics_workspace_name = try(local.config.log_analytics_workspace_name, null) != null ? local.config.log_analytics_workspace_name : var.log_analytics_workspace_name # "gcci-agency-workspace"  # DO NOT CHANGE
}  

