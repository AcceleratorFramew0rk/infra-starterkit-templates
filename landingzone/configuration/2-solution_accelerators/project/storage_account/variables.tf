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

# allow cusomization of the private endpoint subnet name
variable "subnet_name" {
  type        = string  
  default = "ServiceSubnet"
}


# developer portal variables

# account_replication_type      = "LRS" # "GRS" (readonly)
# account_tier                  = "Standard" (readonly)
# account_kind                  = "StorageV2" (readonly)
# PEP                          = "yes" (readonly)



variable "type" {
  type        = string  
  default = "LRS"
}

variable "tier" {
  type        = string  
  default = "Standard"
}

variable "kind" {
  type        = string  
  default = "Standard"
}