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

variable "dps_subnet_id" {
  type        = string  
  default = null
}

variable "subnet_name" {
  type        = string  
  default = "WebSubnet"
}

variable "dps_subnet_name" {
  type        = string  
  default = "ServiceSubnet"
}


# developer portal variables
# sku: S1 (default Premium)
# capacity: 1 (readonly)
# pep: yes (readonly)
# pte dns: yes (readonly)

variable "sku" {
  type        = string  
  default = "S1"
}

variable "capacity" {
  type        = string  
  default = "1"
}
