terraform {
  required_version = ">=1.11.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.38.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id            = var.subscription_id
  tenant_id                  = var.tenant_id

}

locals {
  rgname           = azurerm_resource_group.rg1.name
  primary_location = "westus2"       # e.g., "East US"
  replica_location = "westcentralus" # e.g., "West US"
  admin_user       = "msqladmin"
  admin_password   = "P@ssw0rd1234!@#$" # store in KV in real use
}

module "rg1" {
  source   = "./modules/rg"
  rgname   = "rg01"
  location = local.primary_location
}

# call your module like normal
module "mysql_stack" {
  source = "./modules/mysql_stack"
  rgname           = local.rgname
  primary_location = local.primary_location    # e.g., "East US"
  replica_location = local.replica_location # e.g., "West US"
  admin_user       = local.admin_user
  admin_password   = local.admin_password
}


# one thing to target
resource "null_resource" "go" {
  depends_on = [module.mysql_stack]
}
