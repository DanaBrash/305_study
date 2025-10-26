# peer VNET a and VNET b
# Peering must be bidirectional, where vnet a is the hub to transit
# this module is designed to peer any two vnets, while the variable defaults configure a hub (A) and spoke (B) model

resource "azurerm_virtual_network_peering" "a_to_b" {
  resource_group_name = var.rgname

  name                      = var.peering_vnets[0].peering_name
  virtual_network_name      = var.peering_vnets[0].name
  remote_virtual_network_id = var.peering_vnets[1].id

  allow_virtual_network_access = var.peering_vnets[0].allow_virtual_network_access
  allow_forwarded_traffic      = var.peering_vnets[0].allow_forwarded_traffic
  allow_gateway_transit        = var.peering_vnets[0].allow_gateway_transit
  use_remote_gateways          = var.peering_vnets[0].use_remote_gateways
}


resource "azurerm_virtual_network_peering" "b_to_a" {
  resource_group_name = var.rgname

  name                      = var.peering_vnets[1].peering_name
  virtual_network_name      = var.peering_vnets[1].name
  remote_virtual_network_id = var.peering_vnets[0].id

  allow_virtual_network_access = var.peering_vnets[1].allow_virtual_network_access
  allow_forwarded_traffic      = var.peering_vnets[1].allow_forwarded_traffic
  allow_gateway_transit        = var.peering_vnets[1].allow_gateway_transit
  use_remote_gateways          = var.peering_vnets[1].use_remote_gateways
}
