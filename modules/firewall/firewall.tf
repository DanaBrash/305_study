# Helpful maps for clean for_each keys
locals {
  vnets_by_name = { for v in var.vnets : v.name => v }
  # key subnets by "vnet/name" so they’re unique and addressable
  subnets_by_key = {
    for s in var.subnets :
    "${s.vnet_name}/${s.name}" => s
  }
  firewalls_by_name = { for f in var.firewalls : f.name => f }
}

# 2) virtual networks
resource "azurerm_virtual_network" "vnet" {
  for_each            = local.vnets_by_name
  name                = each.value.name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = each.value.address_space
}

# 3) subnets
resource "azurerm_subnet" "subnet" {
  for_each             = local.subnets_by_key
  name                 = each.value.name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet[each.value.vnet_name].name
  address_prefixes     = each.value.address_prefixes
}

# 4) public IPs for firewalls (one per firewall)
resource "azurerm_public_ip" "fw_pip" {
  for_each            = local.firewalls_by_name
  name                = each.value.pip_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# 5) firewalls
resource "azurerm_firewall" "fw" {
  for_each            = local.firewalls_by_name
  name                = each.value.name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku_name            = "AZFW_VNet"
  sku_tier            = each.value.sku_tier

  # find the firewall subnet inside the chosen vnet
  dynamic "ip_configuration" {
    for_each = [each.value] # single block
    content {
      name                 = "configuration"
      subnet_id            = azurerm_subnet.subnet["${each.value.vnet_name}/${each.value.subnet_name}"].id
      public_ip_address_id = azurerm_public_ip.fw_pip[each.key].id
    }
  }
}
