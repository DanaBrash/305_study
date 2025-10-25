
variable "location" {
  description = "The Azure region where resources will be created."
  type        = string
  default     = "West US 2"
}

variable "rgname" {
  description = "The Azure region where resources will be created."
  type        = string
}

variable "subscription_id" {
  description = "The Azure subscription ID."
  type        = string
}

variable "tenant_id" {
  description = "The Azure tenant ID."
  type        = string
}

variable "vnets" {
  description = "Virtual networks to create"
  type = list(object({
    name          = string
    address_space = list(string)
  }))
  default = [
    {
      name          = "vnet1"
      address_space = ["10.10.0.0/16"]
    },
    {
      name          = "vnet2"
      address_space = ["10.20.0.0/16"]
    }
  ]
}

# using default is redundant with sample call from main at root, but used for portability
variable "subnets" {
  description = "Subnets to create; vnet_name must match a vnet above"
  type = list(object({
    vnet_name        = string
    name             = string
    address_prefixes = list(string)
  }))
  default = [
    # vnet1
    {
      vnet_name        = "vnet1"
      name             = "AzureFirewallSubnet" # required literal name for Azure Firewall
      address_prefixes = ["10.10.0.0/24"]
    },
    {
      vnet_name        = "vnet1"
      name             = "subnet1"
      address_prefixes = ["10.10.10.0/24"]
    },

    # vnet2
    {
      vnet_name        = "vnet2"
      name             = "AzureFirewallSubnet"
      address_prefixes = ["10.20.0.0/24"]
    },
    {
      vnet_name        = "vnet2"
      name             = "app"
      address_prefixes = ["10.20.10.0/24"]
    }
  ]
}