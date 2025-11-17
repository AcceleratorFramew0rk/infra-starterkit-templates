variable "client_id" {
  default="azureaksuser"
}

variable "client_secret" {
  default="!qaz@wsx@1234567890"
}

variable "key_vault_firewall_bypass_ip_cidr" {
  type    = string
  default = null
}

variable "managed_identity_principal_id" {
  type    = string
  default = null
}

variable "tags" {
  default = {
    purpose = "aks cluster" 
    project_code = "aoaidev" # local.global_settings.prefix 
    env = "sandpit" # local.global_settings.environment 
    zone = "project"
    tier = "app"  
  }
}

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

variable "systemnode_subnet_id" {
  type        = string  
  default = null
}

variable "usernode_subnet_id" {
  type        = string  
  default = null
}

variable "usernodeintranet_subnet_id" {
  type        = string  
  default = null
}

variable "usernodewindows_subnet_id" {
  type        = string  
  default = null
}

variable "systemnode_subnet_name" {
  type        = string  
  default = "SystemNodePoolSubnet"
}

variable "usernode_subnet_name" {
  type        = string  
  default = "UserNodePoolSubnet"
}

variable "usernodeintranet_subnet_name" {
  type        = string  
  default = "UserNodePoolIntranetSubnet"
}

variable "usernodewindows_subnet_name" {
  type        = string  
  default = "UserNodePoolWindowsSubnet"
}

variable "kubernetes_version" {
  description = "Specifies the AKS Kubernetes version"
  default     = "1.33" # "1.26.3"
  type        = string
}

variable "acr_subnet_name" {
  type        = string  
  default = "ServiceSubnet"
}

variable "acr_subnet_id" {
  type        = string  
  default = null
}

# developer portal variables
# min_count: 2 (default 2)
# max_count: 8 (default 8)
# vm_size:  Standard_D4_v3 (default Standard_D4_v3)
# version: 1.31 (readonly)

variable "min_count" {
  type        = string  
  default = "2"
}

variable "max_count" {
  type        = string  
  default = "8"
}

variable "vm_size" {
  type        = string  
  default = "Standard_D2d_v5" # "Standard_D4_v3"
}

