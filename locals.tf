locals {
  rgname           = "rg1"
  fw_rgname        = format("%s-fw", module.naming.resource_group.name)
  suffix           = ["305"]
  projName         = "study"
  primary_location = "westus2"       # e.g., "East US"
  replica_location = "westcentralus" # e.g., "West US"
  admin_user       = "305admin"
  admin_password   = "P@ssw0rd1234!@#$" # store in KV in real use

  # vnets for firewall module
  fw_vnets = [
    {
      name          = "vnet1"
      address_space = ["10.10.0.0/16"]
    },
    {
      name          = "vnet2"
      address_space = ["10.20.0.0/16"]
    }
  ]

  # subnets for firewall module
  fw_subnets = [
    # vnet1
    {
      vnet_name        = "vnet1"
      name             = "AzureFirewallSubnet" # required literal name for Azure Firewall
      address_prefixes = ["10.10.0.0/24"]
    },
    {
      vnet_name        = "vnet1"
      name             = "subnet1-1"
      address_prefixes = ["10.10.10.0/24"]
    },

    # vnet2 - to prepare for peering and testing as needed
    {
      vnet_name        = "vnet2"
      name             = "subnet2-1"
      address_prefixes = ["10.20.0.0/24"]
    },
    {
      vnet_name        = "vnet2"
      name             = "subnet2-2"
      address_prefixes = ["10.20.10.0/24"]
    }
  ]

  peering_vnets = [
    {
      name                         = "vnet1"
      peering_name                 = "vnet1-to-vnet2"
      id                           = module.fw_network.vnets_by_name["vnet1"].id
      allow_forwarded_traffic      = true
      allow_gateway_transit        = true
      allow_virtual_network_access = true
      use_remote_gateways          = false
    },
    {
      name                         = "vnet2"
      peering_name                 = "vnet2-to-vnet1"
      id                           = module.fw_network.vnets_by_name["vnet2"].id
      allow_virtual_network_access = true
      allow_forwarded_traffic      = true
      allow_gateway_transit        = false
      use_remote_gateways          = false
    }
  ]

}
