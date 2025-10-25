/**
 * outputs.tf
 *
 * Exposes VNets and Subnets in different forms:
 * - vnets_by_name: compact facts (id, name, address_space)
 * - vnet_ids: map of VNet ids by name
 * - vnet_names: list of all VNet names
 * - subnets_by_key: compact facts keyed by "vnet/subnet"
 * - subnet_ids: map of subnet ids keyed by "vnet/subnet"
 * - subnet_names: list of all subnet names created
 */

# ---- Virtual Networks ----

output "rgname" {
  description = "The resource group name used for all firewalls and public IPs."
  value       = var.rgname
}

output "vnets_by_name" {
  description = "Map keyed by VNet name with id, name, and address_space."
  value = {
    for name, vnet in azurerm_virtual_network.vnets :
    name => {
      id            = vnet.id
      name          = vnet.name
      address_space = vnet.address_space
    }
  }
}

output "vnet_ids" {
  description = "Map of VNet ids keyed by VNet name."
  value       = { for name, vnet in azurerm_virtual_network.vnets : name => vnet.id }
}

output "vnet_names" {
  description = "List of all VNet names created."
  value       = [for v in azurerm_virtual_network.vnets : v.name]
}


# ---- Subnets ----

output "subnets_by_key" {
  description = "Map keyed by 'vnet/subnet' with id, name, and address_prefixes."
  value = {
    for key, subnet in azurerm_subnet.subnets :
    key => {
      id              = subnet.id
      name            = subnet.name
      address_prefixes = subnet.address_prefixes
    }
  }
}

output "subnet_ids" {
  description = "Map of subnet ids keyed by 'vnet/subnet'."
  value       = { for key, subnet in azurerm_subnet.subnets : key => subnet.id }
}

output "subnet_names" {
  description = "List of all subnet names created."
  value       = [for s in azurerm_subnet.subnets : s.name]
}
