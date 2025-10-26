/**
 * outputs.tf

 * CHATGPT generated file
 *
 * Exposes useful views of the Key Vaults and any role assignments created here.
 * Works with azurerm_key_vault.key_vault_1 defined with for_each = var.kv_map.
 */

output "key_vaults_by_key" {
  description = "Map keyed by kv_map key with common fields for each Key Vault."
  value = {
    for k, kv in azurerm_key_vault.key_vault_1 :
    k => {
      id          = kv.id
      name        = kv.name
      rg          = kv.resource_group_name
      location    = kv.location
      vault_uri   = kv.vault_uri
      tenant_id   = kv.tenant_id
      sku_name    = kv.sku_name
      purge_protection_enabled   = kv.purge_protection_enabled
      soft_delete_retention_days = kv.soft_delete_retention_days
      rbac_authorization_enabled = kv.rbac_authorization_enabled
      enabled_for_disk_encryption = kv.enabled_for_disk_encryption
    }
  }
}

output "key_vault_ids" {
  description = "Map of Key Vault IDs keyed by kv_map key."
  value       = { for k, kv in azurerm_key_vault.key_vault_1 : k => kv.id }
}

output "key_vault_names" {
  description = "List of Key Vault names created."
  value       = [for kv in azurerm_key_vault.key_vault_1 : kv.name]
}

output "key_vault_uris" {
  description = "Map of vault_uri endpoints keyed by kv_map key."
  value       = { for k, kv in azurerm_key_vault.key_vault_1 : k => kv.vault_uri }
}

# If you are creating reader assignments in this module:
# azurerm_role_assignment.key_vault_reader uses for_each
# Expose a compact view keyed by the role-assignment key.
output "role_assignments_reader" {
  description = "Key Vault Reader role assignments keyed by '<kvKey>|<principalId>'."
  value = try({
    for k, ra in azurerm_role_assignment.key_vault_reader :
    k => {
      id          = ra.id
      scope       = ra.scope
      principal_id = ra.principal_id
      role        = ra.role_definition_name
    }
  }, {})
}

# If you are creating contributor assignments in this module:
output "role_assignments_contributor" {
  description = "Key Vault Contributor role assignments keyed by '<kvKey>|<principalId>'."
  value = try({
    for k, ra in azurerm_role_assignment.key_vault_contributor :
    k => {
      id           = ra.id
      scope        = ra.scope
      principal_id = ra.principal_id
      role         = ra.role_definition_name
    }
  }, {})
}
