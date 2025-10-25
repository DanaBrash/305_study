# Helpful maps for clean for_each keys
locals {
  firewalls_by_name = { for f in var.firewalls : f.name => f }
}

# public IPs for firewalls (one per firewall)
resource "azurerm_public_ip" "fw_pip" {
  for_each            = local.firewalls_by_name
  name                = each.value.pip_name
  resource_group_name = var.rgname
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# firewalls
resource "azurerm_firewall" "fw" {
  for_each            = local.firewalls_by_name
  name                = each.value.name
  resource_group_name = var.rgname
  location            = var.location
  sku_name            = "AZFW_VNet"
  sku_tier            = each.value.sku_tier

  # find the firewall subnet inside the chosen vnet
  dynamic "ip_configuration" {
    for_each = [each.value] # single block
    content {
      name                 = "configuration"
      subnet_id            = var.subnet_id
      public_ip_address_id = azurerm_public_ip.fw_pip[each.key].id
    }
  }
}
