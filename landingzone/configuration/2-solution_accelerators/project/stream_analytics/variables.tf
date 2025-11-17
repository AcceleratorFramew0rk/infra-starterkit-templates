# insert your variables here
variable "location" {
  type        = string  
  default = "southeastasia"
}

variable "vnet_id" {
  type        = string  
  default = null
}

variable "subnet_id" {
  type        = string  
  default = null
}

variable "log_analytics_workspace_id" {
  type        = string  
  default = null
}

variable "prefix" {
  type        = string  
  default = "aaf"
}

variable "environment" {
  type        = string  
  default = "sandpit"
}

# developer portal variables
# PEP iot_hub_id: Yes (readonly)
# PEP data_explorer_id: Yes (readonly)
# PEP eventhub_namespace_id: Yes (readonly)
# PEP sql_server_id: Yes (readonly)

  # iot_hub_id = try(local.iothub_id , null) 
  # data_explorer_id = try(local.dataexplorer.resource.id, null) 
  # eventhub_namespace_id = try(local.eventhubs.eventhub_namespace_id, null) 
  # sql_server_id = try(local.sqlserver.id, null) 
