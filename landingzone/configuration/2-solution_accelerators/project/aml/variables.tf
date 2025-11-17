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

# variable "deployment_machine_ips_32" {
#   description = <<EOF
#   List of IP addresses for the machines (e.g. gitlab runners) that will be used to deploy the resources.
#   If you are deploying the templates directly from SEED, you may leave this as an empty list.
#   For SGTS Gitlab Runners, you may retrieve the IPs from here:
#   https://docs.developer.tech.gov.sg/docs/ship-hats-docs/tools/gitlab/gitLab-dedicated-server-egress-ips
#   EOF
#   type        = list(string)
#   default = [
#     "13.251.177.7/32",
#     "18.143.61.190/32"
#   ]

#   validation {
#     condition = alltrue([
#       for ip in var.deployment_machine_ips :
#       can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", ip))
#     ])
#     error_message = "Each item in deployment_machine_ips must be a valid IPv4 address."
#   }
# }


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
