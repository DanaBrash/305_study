locals {
  # extract the userids from the user objects
  key_vault_readers_upn = [
    for u in var.key_vault_readers : "${u}@${var.domain_name}"
  ]

  key_vault_contributors_upn = [
    for u in var.key_vault_contributors : "${u}@${var.domain_name}"
  ]

  # map the upn to the object id  
  kv_reader_id_by_upn = {
    for u in data.azuread_users.key_vault_reader.users :
    lower(u.user_principal_name) => u.object_id
  }

  kv_contributor_id_by_upn = {
    for u in data.azuread_users.key_vault_contributor.users :
    lower(u.user_principal_name) => u.object_id
  }


  # flatten the vault and uid 
  kv_reader_pairs = flatten([
    for kv_key, kv in azurerm_key_vault.key_vault_1 : [
      for upn in local.key_vault_readers_upn : {
        key          = "${kv_key}|${lookup(local.kv_reader_id_by_upn, lower(upn), "missing")}"
        scope        = kv.id
        principal_id = lookup(local.kv_reader_id_by_upn, lower(upn), null)
      } if lookup(local.kv_reader_id_by_upn, lower(upn), null) != null
    ]
  ])

kv_contributor_pairs = flatten([
    for kv_key, kv in azurerm_key_vault.key_vault_1 : [
      for upn in local.key_vault_contributors_upn : {
        key          = "${kv_key}|${lookup(local.kv_contributor_id_by_upn, lower(upn), "missing")}"
        scope        = kv.id
        principal_id = lookup(local.kv_contributor_id_by_upn, lower(upn), null)
      } if lookup(local.kv_contributor_id_by_upn, lower(upn), null) != null
    ]
  ])



}
