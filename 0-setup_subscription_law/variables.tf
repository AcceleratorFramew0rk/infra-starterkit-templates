variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see https://aka.ms/avm/telemetryinfo.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

variable "name_prefix" {
  description = "(Optional) A prefix for the name of all the resource groups and resources."
  type        = string
  default     = "subscription-monitor-law"
  nullable    = true
}

variable "location" {
  description = "(Optional) A prefix for the location of all the resource groups and resources."
  type        = string
  default     = "southeastasia"
  nullable    = true
}

# log analytics workspace
variable "solution_plan_map" {
  description = "Specifies solutions to deploy to log analytics workspace"
  default     = {
    ContainerInsights= {
      product   = "OMSGallery/ContainerInsights"
      publisher = "Microsoft"
    }
  }
  type = map(any)
}

# others
variable "tags" {
  description = "(Optional) Specifies tags for all the resources"
  default     = {
    createdWith = "Terraform"
    env = "sandpit"
  }
}


variable "log_analytics_workspace_resource_group_name" {
  type        = string  
  description = "(Optional) Specifies log_analytics_workspace_resource_group_name of gcci_platform"
  default     = "central-agency-law"
}

variable "log_analytics_workspace_name" {
  type        = string  
  description = "(Optional) Specifies log_analytics_workspace_name of gcci_platform"
  default     = "central-agency-workspace"
}
