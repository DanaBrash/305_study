variable "location" {
  description = "The Azure region where resources will be created."
  type        = string
  default     = "West US 2"
}

variable "subscription_id" {
  description = "The Azure subscription ID."
  type        = string
}

variable "tenant_id" {
  description = "The Azure tenant ID."
  type        = string
}

variable "rg" {
  description = "Target resource group"
  type = object({
    name     = string
    location = string
  })
  default = {
    name     = "rg-net-demo"
    location = "westus2"
  }
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

variable "firewalls" {
  description = "Firewalls to deploy; subnet_name must be AzureFirewallSubnet inside the target vnet"
  type = list(object({
    name       = string
    vnet_name  = string
    subnet_name = string          # usually "AzureFirewallSubnet"
    pip_name   = string           # public IP name to create/use
    sku_tier   = optional(string, "Premium") # Standard or Premium
  }))
  default = [
    {
      name        = "fw1"
      vnet_name   = "vnet1"
      subnet_name = "AzureFirewallSubnet"
      pip_name    = "pip-fw1"
      sku_tier    = "Premium"
    },
    {
      name        = "fw2"
      vnet_name   = "vnet2"
      subnet_name = "AzureFirewallSubnet"
      pip_name    = "pip-fw2"
      sku_tier    = "Standard"
    }
  ]
}
