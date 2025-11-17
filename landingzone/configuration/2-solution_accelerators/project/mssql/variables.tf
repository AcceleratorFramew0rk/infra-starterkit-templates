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
# tier: Standard 
# elastic pool capacity: 50, 100, 200  (default 50)
# Max size (gc) : 50 (readonly)
# pep: yes (readonly)

variable "tier" {
  type        = string  
  default = "Standard"
}

variable "max_capacity" {
  type        = string  
  default = "50"
}

variable "max_size" {
  type        = string  
  default = "50"
}
