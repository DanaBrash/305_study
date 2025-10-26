data "azuread_users" "key_vault_reader" {
  user_principal_names = local.key_vault_readers_upn
}

data "azuread_users" "key_vault_contributor" {
  user_principal_names = local.key_vault_contributors_upn
}