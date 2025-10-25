locals {
  rgs_by_index = { for idx, rg in var.rgs : idx => rg }
}

resource "azurerm_resource_group" "rg" {
  for_each = local.rgs_by_index
  name     = each.value.name
  location = each.value.location
}