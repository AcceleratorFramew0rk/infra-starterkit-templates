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
  default = "AgentServiceSubnet"
}

variable "private_endpoint_subnet_name" {
  type        = string  
  default = "ServiceSubnet"
}

variable "private_endpoint_subnet_id" {
  type        = string  
  default = null
}

# This is to allow ingress from SEED Devices to access Foundry for Development
variable "ingress_client_ip" {
  description = <<EOF
  Allowlist for Ingress IPs. The default value is set to the current CloudFlare IPs subjected to future updates if and when SEED has changes to the IPs"
  EOF
  type        = list(string)
  default = [
    "8.29.230.18",
    "8.29.230.19",
    "104.30.161.22",
    "104.30.161.23",
    "104.30.161.24",
    "104.30.161.25"
  ]

  validation {
    condition = alltrue([
      for ip in var.ingress_client_ip :
      can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", ip))
    ])
    error_message = "Each item in ingress_client_ip must be a valid IPv4 address."
  }
}


variable "deployment_machine_ips" {
  description = <<EOF
  List of IP addresses for the machines (e.g. gitlab runners) that will be used to deploy the resources.
  If you are deploying the templates directly from SEED, you may leave this as an empty list.
  For SGTS Gitlab Runners, you may retrieve the IPs from here:
  https://docs.developer.tech.gov.sg/docs/ship-hats-docs/tools/gitlab/gitLab-dedicated-server-egress-ips
  EOF
  type        = list(string)
  default = [
    "13.251.177.7",
    "18.143.61.190"
  ]

  validation {
    condition = alltrue([
      for ip in var.deployment_machine_ips :
      can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", ip))
    ])
    error_message = "Each item in deployment_machine_ips must be a valid IPv4 address."
  }
}

## As of 6/2025 this is limited to RFC1918 Class B and Class C address space
variable "virtual_network_address_space" {
  description = "The address space for the virtual network"
  type        = string
  default     = "192.168.20.0/22"
}

variable "agent_subnet_address_prefix" {
  description = "The address prefix for the subnet that will be delegated to the Standard Agent"
  type        = string
  default     = "192.168.20.0/24"
}

variable "private_endpoint_subnet_address_prefix" {
  description = "The address prefix for the subnet that contains the private endpoints"
  type        = string
  default     = "192.168.21.0/24"
}

# developer portal variables
# sku: S0
# pep: yes (readonly)
# pte dns: yes (readonly)

# variable "sku" {
#   type        = string
#   default = "S0"
# }