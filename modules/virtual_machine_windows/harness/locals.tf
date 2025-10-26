locals {
  rgname   = module.naming.virtual_machine.name
  location = "West US 2"
  suffix   = "harness"


  # vnets for firewall module
  vnets = [
    {
      name          = "vnet1"
      address_space = ["172.16.38.0/23"]
    },
  ]

  # subnets for firewall module
  subnets = [
    # vnet1
    {
      vnet_name        = "vnet1"
      name             = "default"
      address_prefixes = ["172.16.38/24"]
    },
  ]

  

}

