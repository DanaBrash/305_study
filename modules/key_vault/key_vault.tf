data "azurerm_client_config" "current" {}


resource "azurerm_key_vault" "keyVault1" {
  name                = "cala-kv-1"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location

  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

}

/*
resource "azurerm_key_vault" "keyVault1" {
  name                = "cala-kv-1"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location

  sku_name = "standard"

  tenant_id = "6dd7381d-4ace-410a-b7f3-011a192ebe60" # var.tenant_id

  enabled_for_disk_encryption = true
  soft_delete_retention_days  = 7
  enable_rbac_authorization   = true
  purge_protection_enabled    = false

  lifecycle {
    ignore_changes = [contact,access_policy]
  }

  tags = {
    environment = "study"
  }
}

resource "azurerm_role_assignment" "keyvault_access" {
  scope              = azurerm_key_vault.keyVault1.id
  role_definition_name = "Key Vault Administrator"
  principal_id       = "ac33bdf6-630e-46c6-b92f-c07153e73835" # "f4523d2a-b848-4b27-87ff-aeea282e086f"
}

resource "azurerm_key_vault_key" "kvkey1" {
  name         = "kv-gen-key1"
  key_vault_id = azurerm_key_vault.keyVault1.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  rotation_policy {
    automatic {
      time_before_expiry = "P30D"
    }

    expire_after         = "P90D"
    notify_before_expiry = "P29D"
  }
}
*/
