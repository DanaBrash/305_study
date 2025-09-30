resource "azurerm_monitor_workspace" "monitor_workspace" {
  name                = "monitor-workspace"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  tags = {
    environment = "production"
    team        = "monitoring"
  }
  
}