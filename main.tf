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
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id

}

module "naming" {
  source = "git::https://github.com/DanaBrash/calabashnaming.git"
  suffix = local.suffix
}

# I like to create all the RGs up front, but the module and module names could be individual based on preference
module "rg" {
  source = "./modules/resource_group"
  rgs = [
    {
      name     = local.rgname
      location = local.primary_location
    },
    {
      name     = local.fw_rgname
      location = local.primary_location
    }
  ]
}


# call mysql module
module "mysql_stack" {
  source           = "./modules/mysql_stack"
  subscription_id  = var.subscription_id
  tenant_id        = var.tenant_id
  rgname           = local.rgname
  primary_location = local.primary_location # e.g., "East US"
  replica_location = local.replica_location # e.g., "West US"
  admin_user       = local.admin_user
  admin_password   = local.admin_password
}

# create the newtorking for the firwall deployment
module "fw_network" {
  source          = "./modules/virtual_network"
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
  rgname          = local.fw_rgname 
  vnets           = local.fw_vnets
  subnets         = local.fw_subnets
}

module "fw_peering" {
  source        = "./modules/virtual_network_peering"
  rgname        = local.fw_rgname 
  peering_vnets = local.peering_vnets
}

# call firewall module
module "firewall" {
  source          = "./modules/firewall"
  location        = local.primary_location
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  subnet_id       = module.fw_network.subnets_by_key["vnet1/AzureFirewallSubnet"].id
  rgname          = local.fw_rgname

  firewalls = [
    {
      name        = "fw1"
      vnet_name   = "vnet1"
      subnet_name = "AzureFirewallSubnet"
      pip_name    = "pip-fw1"
      sku_tier    = "Standard"
    }
  ]
}

module "virtual_machine_windows" {
  source          = "./modules/virtual_machine_windows"
  location        = var.location
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  rgname          = module.rg.resource_groups_by_name[local.rgname].name
  subnet_id       = module.fw_network.subnets_by_key["vnet1/subnet1-1"].id
}


# one thing to target, as opposed to just targeting it(?) This is what ChatGPT came up with to manage dependencies. 
# Interesting idea, but I think modules should manage their own dependencies...
resource "null_resource" "go" {
  depends_on = [module.mysql_stack]
}

resource "null_resource" "fw" {
  depends_on = [module.rg, module.fw_network, module.fw_peering, module.firewall]
}
