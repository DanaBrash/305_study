terraform {
  required_version = ">=1.11.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.38.0"
    }
  }
}


module "naming" {
  source = "git::https://github.com/DanaBrash/calabashnaming.git"
  suffix = [local.suffix]
}


module "rg" {
  source = "../../../modules/resource_group" # https://github.com/DanaBrash/305_study/tree/dev/modules/resource_group use the right one
  rgs = [
    {
      name     = module.naming.resource_group.name
      location = local.location
    }
  ]
}


module "key_vault" {
  source = "../"
  kv_map = {
    kv1 = {
      name                        = module.naming.key_vault.name
      tenant_id                   = var.tenant_id
      rgname                      = module.rg.resource_groups_by_name[local.rgname].name
      location                    = module.rg.resource_groups_by_name[local.rgname].location
      sku_name                    = "standard"
      rbac_authorization_enabled  = true
      enabled_for_disk_encryption = true
      soft_delete_retention_days  = 7
      purge_protection_enabled    = false
    }
  }
  key_vault_readers      = local.key_vault_readers
  key_vault_contributors = local.key_vault_contributors
  domain_name            = var.domain_name
}
