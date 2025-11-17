# insert your variables here
variable "location" {
  type        = string  
  default = "southeastasia"
}

variable "ai_services_location" {
  type        = string  
  default = "eastus2" # "southeastasia" - many model not availble in southeastasia
}

variable "vnet_id" {
  type        = string  
  default = null
}

variable "subnet_id" {
  type        = string  
  default = null
}

variable "private_endpoint_subnet_id" {
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
  default = "AiSubnet"
}

variable "private_endpoint_subnet_name" {
  type        = string  
  default = "ServiceSubnet"
}


variable "public_network_access_enabled" {
  type        = bool  
  default = true
}

variable "ai_hub_is_private" {
  type        = bool  
  default = false
}


# developer portal variables
# sku: 50 (default 50) (readonly)
# subnet_name: AiSubnet (readonly)
# pep: yes (readonly)
# pte dns: yes (readonly)


# sku_name - (Required) Specifies the SKU Name for this AI Services Account. Possible values are F0, F1, S0, S, S1, S2, S3, S4, S5, S6, P0, P1, P2, E0 and DC0
variable "sku" {
  type        = string  
  default = "S0"
}
