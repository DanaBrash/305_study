resource "azurerm_key_vault" "key_vault_1" {
  for_each = var.kv_map

  name                        = each.value.name
  resource_group_name         = each.value.rgname
  location                    = each.value.location
  rbac_authorization_enabled  = each.value.rbac_authorization_enabled
  enabled_for_disk_encryption = each.value.enabled_for_disk_encryption
  tenant_id                   = each.value.tenant_id
  soft_delete_retention_days  = each.value.soft_delete_retention_days
  purge_protection_enabled    = each.value.purge_protection_enabled
  sku_name                    = each.value.sku_name
}

# add users to rbac kv reader role
resource "azurerm_role_assignment" "key_vault_reader" {
  for_each = { for p in local.kv_reader_pairs : p.key => p }

  scope                = each.value.scope
  role_definition_name = "Key Vault Reader"
  principal_id         = each.value.principal_id
}

# add users to rbac kv contributor role
resource "azurerm_role_assignment" "key_vault_contributor" {
  for_each = { for p in local.kv_contributor_pairs : p.key => p }

  scope                = each.value.scope
  role_definition_name = "Key Vault Contributor"
  principal_id         = each.value.principal_id
}
