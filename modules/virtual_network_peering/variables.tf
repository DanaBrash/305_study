variable "rgname" {
  description = "Resource group name for firewall resources"
  default     = ""
  type        = string
}

variable "peering_vnets" {
  description = "List of VNETs to peer"
  type = list(object({
    name                         = string
    peering_name                 = string
    id                           = string
    allow_forwarded_traffic      = bool
    allow_gateway_transit        = bool
    allow_virtual_network_access = bool
    use_remote_gateways          = bool
  }))
  default = [
    {
      name                         = "vnet1"
      peering_name                 = "vnet1-to-vnet2"
      id                           = ""
      allow_forwarded_traffic      = true
      allow_gateway_transit        = true
      allow_virtual_network_access = true
      use_remote_gateways          = false
    },
    {
      name                         = "vnet2"
      peering_name                 = "vnet2-to-vnet1"
      id                           = ""
      allow_virtual_network_access = true
      allow_forwarded_traffic      = true
      allow_gateway_transit        = false
      use_remote_gateways          = true
    }
  ]
}
