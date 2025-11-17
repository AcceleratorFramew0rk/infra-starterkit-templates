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
# server_version: 16 (readonly) 
# sku_name: "GP_Standard_D2s_v3"  (default "GP_Standard_D2s_v3")
# zone : 3 (default 3)
# pep: yes (readonly)

variable "server_version" {
  type        = string  
  default = "16"
}

variable "sku_name" {
  type        = string  
  default = "GP_Standard_D2s_v3"
}

variable "zone" {
  type        = string  
  default = "1"
}
