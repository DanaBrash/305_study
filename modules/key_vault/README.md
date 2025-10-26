# Key Vault Module
***THIS README.md IS CHATGPT GENERATED: REVIEW BEFORE USE***

Creates one or more Azure Key Vaults from a map and (optionally) assigns RBAC roles to Azure AD users you specify by username plus a private domain.

- Multiple vaults via `for_each = var.kv_map`
- Reader and contributor RBAC using Azure AD **object IDs** looked up from **UPNs**
- Clean separation of public usernames and private domain name

## Usage

```hcl
module "key_vault" {
  source = "./modules/key_vault"

  kv_map = {
    kv1 = {
      name                        = "cala-kv-1"
      tenant_id                   = var.tenant_id
      rgname                      = "rg1"
      location                    = "westus2"
      sku_name                    = "standard"
      rbac_authorization_enabled  = true
      enabled_for_disk_encryption = true
      soft_delete_retention_days  = 7
      purge_protection_enabled    = false
    }
    kv2 = {
      name                        = "cala-kv-2"
      tenant_id                   = var.tenant_id
      rgname                      = "rg1"
      location                    = "westus2"
      sku_name                    = "standard"
      rbac_authorization_enabled  = true
      enabled_for_disk_encryption = true
      soft_delete_retention_days  = 7
      purge_protection_enabled    = false
    }
  }

  # Optional: lists of usernames (no domain here)
  key_vault_readers      = var.key_vault_readers      # e.g. ["key_reader_1", "key_reader_2"]
  key_vault_contributors = var.key_vault_contributors # e.g. ["key_contrib_1"]
  domain_name            = var.domain_name            # keep this private in .auto.tfvars
}
