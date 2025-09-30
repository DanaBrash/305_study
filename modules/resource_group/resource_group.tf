resource "azurerm_resource_group" "rg1" {
  for_each = { for rg in var.rgs : rgs.name => rg }
  name     = each.value.name
  location = each.value.location
}
