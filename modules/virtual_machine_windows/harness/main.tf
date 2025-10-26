terraform {
  required_version = ">=1.11.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.38.0"
    }
  }
}


module "naming" {
  source = "git::https://github.com/DanaBrash/calabashnaming.git"
  suffix = [local.suffix]
}

module "rg" {
  source = "git::https://github.com/DanaBrash/305_study.git//modules/resource_group?ref=dev"
  rgs = [
    {
      name     = module.naming.resource_group.name
      location = local.location
    }
  ]
}

module "vm_network" {
  source          = "../../backlog/virtual_network"
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
  rgname          = module.rg.resource_groups_by_name[local.rgname].name
  vnets           = local.vnets
  subnets         = local.subnets
}


module "virtual_machine_windows" {
  source    = "../"
  rgname    = module.rg.resource_groups_by_name[local.rgname].name
  location  = local.location
  subnet_id = module.vm_network.subnets_by_name[local.subnets[0].name].id
  vm_config = {
    vm1 = {
      name                         = module.naming.virtual_machine.name
      size                         = var.vm_config["vm1"].size
      admin_username               = var.vm_config["vm1"].admin_username
      admin_password               = var.vm_config["vm1"].admin_password
      os_disk_caching              = var.vm_config["vm1"].os_disk_caching
      os_disk_storage_account_type = var.vm1_config["vm1"].os_disk_storage_account_type

      vnet_interface = {
        v_int1 = {
          name                          = var.vm_config["vm1"].vnet_interface["v_int1"].name
          subnet_id                     = module.vm_network.subnets_by_name["default"].id
          private_ip_address_allocation = var.vm_config["vm1"].vnet_interface["v_int1"].private_ip_address_allocation
          ip_configuration = {
            name                          = var.vm_config["vm1"].vnet_interface["v_int1"].ip_configuration["ipconfig1"].name
            subnet_id                     = module.vm_network.subnets_by_name["default"].id
            private_ip_address_allocation = var.vm_config["vm1"].vnet_interface["v_int1"].ip_configuration["ipconfig1"].private_ip_address_allocation
          }
        }
      }

      image_publisher = var.vm_config["vm1"].image_publisher
      image_offer     = var.vm_config["vm1"].image_offer
      image_sku       = var.vm_config["vm1"].image_sku
      image_version   = var.vm_config["vm1"].image_version
    }
  }
}
