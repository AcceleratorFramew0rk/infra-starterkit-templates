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
  default = "ApiSubnet"
}

variable "publisher_name" {
  type        = string  
  default = "Apim Publisher"
}

variable "publisher_email" {
  type        = string  
  default = "company@terraform.io"
}


# developer portal variables
# sku: Developer_1, Premium (default null)
# virtual_network_type: internal (readonly) 

variable "sku_name" {
  type        = string  
  default = null
}
