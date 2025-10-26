# -----------------------------
# Variables (adjust to taste)
# -----------------------------
variable "rgname" { type = string } # existing RG for all resources
variable "primary_location" { type = string } # e.g., "East US"
variable "replica_location" { type = string } # e.g., "West US"
variable "admin_user" { type = string }
variable "admin_password" { type = string } # store in KV in real use
variable "sku_name" {
  type    = string
  default = "GP_Standard_D2ds_v4"
} # GP or BC tier required for replicas
variable "mysql_version" {
  type    = string
  default = "8.0.21"
}
variable "client_ip" {
  type    = string
  default = "0.0.0.0"
} # your IP; use 0.0.0.0 only for testing


# -----------------------------
# PRIMARY SERVER
# -----------------------------
resource "azurerm_mysql_flexible_server" "primary" {
  name                = "mysql-flex-primary"
  resource_group_name = var.rgname
  location            = var.primary_location
  version             = var.mysql_version

  administrator_login    = var.admin_user
  administrator_password = var.admin_password

  sku_name = var.sku_name

  # backup settings are top-level on MySQL Flexible
  backup_retention_days        = 7
  # if your provider version supports it, this enables geo-redundant backups
  # remove it if your version errors on this field
  geo_redundant_backup_enabled = true

  storage {
    size_gb = 64
    iops    = 600
  }

  # optional
  # high_availability { mode = "SameZone" }
}

# Optional: create an initial DB
resource "azurerm_mysql_flexible_database" "appdb" {
  name                = "appdb"
  resource_group_name = var.rgname
  server_name         = azurerm_mysql_flexible_server.primary.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}

# Simple firewall so you can connect (remove in private networking scenarios)
resource "azurerm_mysql_flexible_server_firewall_rule" "allow_client" {
  name                = "allow-client"
  resource_group_name = var.rgname
  server_name         = azurerm_mysql_flexible_server.primary.name
  start_ip_address    = var.client_ip
  end_ip_address      = var.client_ip
}

# -----------------------------
# READ REPLICA (same region OR cross-region)
# -----------------------------
# Same-RG, same-region replica example
resource "azurerm_mysql_flexible_server" "replica1" {
  name                = "mysql-flex-replica1"
  resource_group_name = var.rgname
  location            = var.primary_location

  create_mode      = "Replica"
  source_server_id = azurerm_mysql_flexible_server.primary.id

  # sku_name must be compatible with the primary (usually same SKU)
  sku_name = var.sku_name
}

# Cross-region replica example (can also use a different RG if you want)
resource "azurerm_mysql_flexible_server" "replica2" {
  name                = "mysql-flex-replica2"
  resource_group_name = var.rgname
  location            = var.replica_location

  create_mode      = "Replica"
  source_server_id = azurerm_mysql_flexible_server.primary.id

  sku_name = var.sku_name
}

# -----------------------------
# Outputs
# -----------------------------
output "primary_fqdn" { value = azurerm_mysql_flexible_server.primary.fqdn }
output "replica1_fqdn" { value = azurerm_mysql_flexible_server.replica1.fqdn }
output "replica2_fqdn" { value = azurerm_mysql_flexible_server.replica2.fqdn }

