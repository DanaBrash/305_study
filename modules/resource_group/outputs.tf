/**
 * outputs.tf
 *
 * Exposes resource groups created by azurerm_resource_group.rg (for_each keyed by index).
 * Provides both index-keyed and name-keyed views.
 */

# ---- Index-keyed (matches the resource for_each keys) ----

output "resource_groups_by_index" {
  description = "Map keyed by numeric index with id, name, and location."
  value = {
    for idx, rg in azurerm_resource_group.rg :
    idx => {
      id       = rg.id
      name     = rg.name
      location = rg.location
    }
  }
}

output "resource_group_ids_by_index" {
  description = "Map of RG ids keyed by numeric index."
  value       = { for idx, rg in azurerm_resource_group.rg : idx => rg.id }
}

output "resource_group_indexes" {
  description = "List of numeric indexes used as for_each keys."
  value       = keys(azurerm_resource_group.rg)
}

# ---- Name-keyed (usually more convenient to consume) ----

output "resource_groups_by_name" {
  description = "Map keyed by RG name with id, name, and location."
  value = {
    for _, rg in azurerm_resource_group.rg :
    rg.name => {
      id       = rg.id
      name     = rg.name
      location = rg.location
    }
  }
}

output "resource_group_ids_by_name" {
  description = "Map of RG ids keyed by RG name."
  value       = { for _, rg in azurerm_resource_group.rg : rg.name => rg.id }
}

output "resource_group_names" {
  description = "List of RG names created."
  value       = [for rg in azurerm_resource_group.rg : rg.name]
}

# ---- Raw map (advanced use) ----

output "resource_groups" {
  description = "Raw map of azurerm_resource_group.rg instances keyed by numeric index."
  value       = azurerm_resource_group.rg
}
