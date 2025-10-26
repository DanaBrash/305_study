terraform {
  # set values in unpublished secrets.auto.tfvars
  backend "azurerm" {
    resource_group_name  = var.state_config.resource_group_name
    storage_account_name = var.state_config.storage_account_name
    container_name       = var.state_config.container_name
    key                  = var.state_config.key
  }
}
