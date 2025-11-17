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

variable "source_image_resource_id" {
  type        = string  
  # example of image resource id
  # "/subscriptions/xxxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx/resourceGroups/aoaiuat-rg-solution-accelerators-project-virtualmachine/providers/Microsoft.Compute/galleries/gccvmgallery/images/vmdefinition001/versions/0.0.1"
  # /subscriptions/xxxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx/resourceGroups/aoaiuat-rg-solution-accelerators-project-virtualmachine/providers/Microsoft.Compute/galleries/gccvmgallery/images/vmdefinition001
  default = null # "/subscriptions/<subscription_id>/resourceGroups/<resource_group>/providers/Microsoft.Compute/images/<custom_image_name>"

}


variable "virtualmachine_os_type" {
  type        = string  
  default = "Windows" # "Windows" or "Linux" 
}

variable "vnet_type" {
  type        = string  
  default = "project" # "" or "project" or "devops" 
}

# allow cusomization of the private endpoint subnet name
variable "subnet_name" {
  type        = string  
  default = "AppSubnet"
}

variable "source_image_reference" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }
}

variable "source_image_reference_linux" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"    
  }
}

variable "encryption_at_host_enabled" {
  type        = bool  
  default = false
}

# # variable deprecated
# variable "resource_names" {
#   description = "List of Virtual Machine names"
#   type        = list(string)
#   default     = ["1"] # default to one virtual machine # ["1", "2"] default to two virtual machines. make sure the vaule is single digit
# }

# variable "cpu" {
#   description = "CPU core for the Virtual Machines to deploy"
#   type        = string
#   default     = null # default to null. make sure the vaule is single digit
# }

# variable "memory" {
#   description = "Memory in MB for the Virtual Machines to deploy"
#   type        = string
#   default     = null # default to null. make sure the vaule is single digit
# }


# developer portal variables
# - os type: windows or linux
# - sku: 2 cpu to 16 cpu
# - storage: 32 to 2 TB
# - count: 1-5

variable "sku" {
  description = "Sku size for the Virtual Machines to deploy"
  type        = string
  default     = "Standard_D8s_v3" 
}

variable "storage" {
  description = "storage in GB for the Virtual Machines to deploy"
  type        = string
  default     = "32" # default to 32. 
}

variable "vm_count" {
  description = "Number Virtual Machines to deploy"
  type        = number
  default     = 1 # default to 1. make sure the vaule is single digit
}

