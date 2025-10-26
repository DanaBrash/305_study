
variable "kv_map" {
  description = "Map of key vault settings"
  type = map(object({
    name = string
    tenant_id = string
    rgname = string
    location = string
    sku_name = string
    rbac_authorization_enabled = bool
    enabled_for_disk_encryption = bool
    soft_delete_retention_days = number
    purge_protection_enabled   = bool
  }))
  default = {
    kv1 = {
    name = "cala-kv-1"
    tenant_id = ""
    rgname = "rg1"
    location = "westus2"
    sku_name = "standard"
    rbac_authorization_enabled = true
    enabled_for_disk_encryption = true
    soft_delete_retention_days = 7
    purge_protection_enabled   = false
    },
    kv2 = {
    name = "cala-kv-2"
    tenant_id = ""
    rgname = "rg1"
    location = "westus2"
    sku_name = "standard"
    rbac_authorization_enabled = true
    enabled_for_disk_encryption = true
    soft_delete_retention_days = 7
    purge_protection_enabled   = false
    }
  }
}

variable "key_vault_readers" {
  description = "List of user names to be assigned Key Vault Reader role"
  type        = list(string)
  default     = []
}

variable "key_vault_contributors" {
  description = "List of user names to be assigned Key Vault Contributor role"
  type        = list(string)
  default     = []
}

variable "domain_name" {
  description = "The domain name for the deployment. (concat for UPN)"
  type        = string
}