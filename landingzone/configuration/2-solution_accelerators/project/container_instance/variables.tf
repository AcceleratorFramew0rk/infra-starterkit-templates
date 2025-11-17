# insert your variables here
variable "location" {
  type        = string  
  default = "southeastasia"
}

variable "vnet_id" {
  type        = string  
  default = null
}

variable "vnet_name" {
  type        = string  
  default = "spoke_project"
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
  default = "CiSubnet"
}

variable "resource_names" {
  description = "List of resource names"
  type        = list(string)
  default     = ["1"] # default to one resource # ["1", "2"] default to two resources. make sure the vaule is single digit
}

variable "image" {
  type        = string  
  default = "acceleratorframew0rk/gccstarterkit-avm-sde:0.3" # "gccstarterkit/gccstarterkit-avm-sde:0.2"
}


# developer portal variables
# cpu: 1 (default 1)
# memory: 2 (default 2)
# os_type: Linux readonly)

variable "cpu" {
  type        = string  
  default = "1"
}

variable "memory" {
  type        = string  
  default = "2"
}
