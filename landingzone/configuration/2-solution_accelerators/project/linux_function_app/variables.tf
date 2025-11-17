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

variable "private_dns_zones_enabled" {
  type        = bool  
  default = true
}

# variable "private_dns_zones_id" {
#   type        = string  
#   default = null
# }

variable "subnet_name" {
  type        = string  
  default = "FunctionAppSubnet"
}

variable "ingress_subnet_name" {
  type        = string  
  default = "ServiceSubnet"
}

variable "ingress_subnet_id" {
  type        = string  
  default = null
}

variable "custom_image_name" {
  type        = string  
  default = null #  "nginx:latest"
}


variable "site_config" {
  description = "Site configuration for the App Service"
  type = object({
    container_registry_use_managed_identity = optional(bool)
    always_on  = optional(bool)
    application_stack = optional(map(object({

    # dotnet_version - (Optional) The version of .NET to use. Possible values include 3.1, 6.0, 7.0, 8.0 and 9.0.
    # use_dotnet_isolated_runtime - (Optional) Should the DotNet process use an isolated runtime. Defaults to false.
    # java_version - (Optional) The Version of Java to use. Supported versions include 8, 11, 17, 21.
    # NOTE:
    # The value 21 is currently in Preview for java_version.
    # node_version - (Optional) The version of Node to run. Possible values include 12, 14, 16, 18 20 and 22.
    # python_version - (Optional) The version of Python to run. Possible values are 3.12, 3.11, 3.10, 3.9, 3.8 and 3.7.
    # powershell_core_version - (Optional) The version of PowerShell Core to run. Possible values are 7, 7.2, and 7.4.
    # use_custom_runtime - (Optional) Should the Linux Function App use a custom runtime?

      dotnet_version              = optional(string)
      java_version                = optional(string)
      node_version                = optional(string)
      powershell_core_version     = optional(string)
      python_version              = optional(string)
      go_version                  = optional(string)
      ruby_version                = optional(string)
      java_server                 = optional(string)
      java_server_version         = optional(string)
      php_version                 = optional(string)
      use_custom_runtime          = optional(bool)
      use_dotnet_isolated_runtime = optional(bool)

      docker = optional(list(object({
        image_name        = string
        image_tag         = string
        registry_password = optional(string)
        registry_url      = string
        registry_username = optional(string)
      })))
    })), {})
  })
  default = {
    container_registry_use_managed_identity = true
    # # TODO: Review the admin_enabled setting
    # # Cloudscape recommendation: App Service apps should enable configuration routing
    # # This control checks whether the App Service application enables configuration routing. The control fails if the application does not enable "vnetImagePullEnabled" and "vnetContentShareEnabled" settings.
    # # Configuration data can be sensitive and should be routed through virtual network rather than the Internet. By routing through the virtual network, the outbound traffic can be restricted/controlled by network security groups (NSGs) and firewalls to prevent data loss.
    vnet_route_all_enabled = true 

    always_on  = true
    application_stack = {
      container = {
        # only one of the following can be set e.g. either docker or one of the other application stacks e.g. node_version
        dotnet_version              = null
        java_version                = null
        node_version                = null
        powershell_core_version     = null
        python_version              = null
        go_version                  = null
        ruby_version                = null
        java_server                 = null
        java_server_version         = null
        php_version                 = null
        use_custom_runtime          = null
        use_dotnet_isolated_runtime = null

        docker = [
          {
            image_name        = "azure-functions/dotnet"
            image_tag         = "4-appservice-quickstart"
            registry_url      = "mcr.microsoft.com"
            # registry_username = "myusername"
            # registry_password = "mypassword"
          }
        ]

      }
    }
  }
}




# developer portal variables
# Type: Linux (readonly)
# PEP: yes (readonly)

