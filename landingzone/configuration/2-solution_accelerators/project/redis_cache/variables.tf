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
  default = "DbSubnet"
}

# developer portal variables
# sku: Premium (readonly)
# capacity: 2 (default 2)
# redis_version : 6 (readonly) or 4
# pep: yes (readonly)

variable "sku_name" {
  type        = string  
  default = "Premium"
}

variable "redis_version" {
  type        = string  
  default = "6"
}

variable "capacity" {
  type        = string  
  default = "2"
}
