
locals {
  vnets_by_name = { for v in var.vnets : v.name => v }
  # key subnets by "vnet/name" so they’re unique and addressable
  subnets_by_key = {
    for s in var.subnets :
    "${s.vnet_name}/${s.name}" => s
  }
}

resource azurerm_virtual_network "vnets" {
  for_each            = local.vnets_by_name
  name                = each.value.name
  resource_group_name = var.rgname
  location            = var.location
  address_space       = each.value.address_space
}

resource azurerm_subnet "subnets" {
  for_each            = local.subnets_by_key
  name                = each.value.name
  resource_group_name = var.rgname
  virtual_network_name = azurerm_virtual_network.vnets[each.value.vnet_name].name
  address_prefixes    = each.value.address_prefixes
}