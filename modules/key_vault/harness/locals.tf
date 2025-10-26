locals {
  rgname   = module.naming.resource_group.name
  suffix   = "305"
  location = "westus2"
  # make sure whatever you put here exists.  just the name, we concat with the domain in the KV module
  key_vault_readers = [
    # add user principal names as needed
    "key_reader_1", "key_reader_2", "key_reader_3"
  ]

  key_vault_contributors = [
    # add user principal names as needed
    "key_contributor_1", "key_contributor_2"
  ]
}


