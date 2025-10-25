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

variable "rgname" {
  description = "Target resource group"
  type = string 
}

variable "subnet_id" {
  description = "The subnet ID where the firewall will be deployed; must be the AzureFirewallSubnet inside the target vnet"
  type        = string
}

variable "firewalls" {
  description = "Firewalls to deploy; subnet_name must be AzureFirewallSubnet inside the target vnet"
  type = list(object({
    name        = string
    vnet_name   = string
    subnet_name = string                      # usually "AzureFirewallSubnet"
    pip_name    = string                      # public IP name to create/use
    sku_tier    = optional(string, "Premium") # Standard or Premium
  }))
  default = [
    {
      name        = "fw1"
      vnet_name   = "vnet1"
      subnet_name = "AzureFirewallSubnet"
      pip_name    = "pip-fw1"
      sku_tier    = "Standard"
    }
  ]
}
