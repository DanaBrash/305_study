resource "azurerm_resource_group" "redis" {
  name     = "rg-redis"
  location = "West US 2"
}

# NOTE: the Name used for Redis needs to be globally unique
resource "azurerm_redis_cache" "redis" {
  name                 = "crei-redis1"
  location             = azurerm_resource_group.redis.location
  resource_group_name  = azurerm_resource_group.redis.name
  capacity             = 1
  family               = "C"
  sku_name             = "Standard"
  non_ssl_port_enabled = false
  minimum_tls_version  = "1.2"

  redis_configuration {
  }
}