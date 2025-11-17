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

variable "subnet_name" {
  type        = string  
  default = "ServiceSubnet"
}

variable "vnet_name" {
  type        = string  
  default = "spoke_project"
}
# developer portal variables
# Purge Protect: yes (readonly) purge_protection_enabled 
# Soft Delete: yes (readonly) soft_delete_retention_days 
# pep: yes (readonly)
# pte dns: yes (readonly)