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
# partition_count: 2 (readonly) 
# message_retention: 7 readonly


variable "partition_count" {
  type        = string  
  default = "2"
}


variable "message_retention" {
  type        = string  
  default = "7"
}

