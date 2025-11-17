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

variable "namespace_type" {
  type        = string  
  default = "NotificationHub"
}


# developer portal variables
# sku_name: "Free" default (free) Free, Basic or Standard
# PEP: Yes (readonly)
# Pte DNS: Yes (readonly)

variable "sku_name" {
  type        = string  
  default = "Free"
}

