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

variable "ingress_subnet_id" {
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
  default = "LogicAppSubnet"
}

variable "ingress_subnet_name" {
  type        = string  
  default = "ServiceSubnet"
}


# developer portal variables
# tier: "WorkflowStandard" default (WorkflowStandard) : possible values include WorkflowStandard, WorkflowPremium, WorkflowConsumption and Standard
# size: "WS1" default (WS1) : Possible values include WS1, WS2, WS3, WS4, WS5, WS6, WS7, WS8, WS9 and WS10
# PEP: yes (readonly)


variable "tier" {
  type        = string  
  default = "WorkflowStandard"
}


variable "size" {
  type        = string  
  default = "WS1"
}

