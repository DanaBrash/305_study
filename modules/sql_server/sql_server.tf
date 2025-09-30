resource "azurerm_mssql_server" "sqlServer" {
  name                = "sql-svr1"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  version             = "12.0"
  minimum_tls_version = "1.2"

  administrator_login          = "creistudyadmin"
  administrator_login_password = "crei1!2@3#4$"
}

resource "azurerm_mssql_elasticpool" "sqlElasticPool" {
  name                = "sql-ep1"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  server_name         = azurerm_mssql_server.sqlServer.name
  max_size_gb         = 10
  # enclave_type        = "Default"

  sku {
    name     = "GP_Gen5"
    capacity = 2 # Number of vCores or DTUs depending on SKU type
    tier     = "GeneralPurpose"
    family   = "Gen5"
  }

  per_database_settings {
    min_capacity = 0.5
    max_capacity = 2.0
  }

  tags = {
    environment = "study"
  }
}


resource "azurerm_mssql_database" "sqlDB" {
  name            = "sql-db1"
  server_id       = azurerm_mssql_server.sqlServer.id
  elastic_pool_id = azurerm_mssql_elasticpool.sqlElasticPool.id
  collation       = "SQL_Latin1_General_CP1_CI_AS"
  license_type    = "LicenseIncluded"
  max_size_gb     = 2
  sku_name        = "ElasticPool"
  # enclave_type    = "Default"

  tags = {
    environment = "study"
  }

}
