resource "azurerm_storage_account" "storage1" {
  name                       = "storage1"
  resource_group_name        = azurerm_resource_group.rg1.name
  location                   = azurerm_resource_group.rg1.location
  account_kind               = "StorageV2"
  account_tier               = "Standard"
  account_replication_type   = "LRS"
  access_tier                = "Hot"
  # https_traffic_only_enabled = true


  network_rules {
    default_action = "Allow"
    bypass         = ["AzureServices"]
  }
}
