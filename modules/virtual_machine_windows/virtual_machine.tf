resource "azurerm_network_interface" "vnet_interface1" {
 for_each = { for vm in var.vm_config : vm.key => vm }
  name                = each.value.vnet_interface.name
  resource_group_name = var.rgname
  location            = var.location
  ip_configuration {
    name                          = each.value.vnet_interface.ip_configuration.name
    subnet_id                     = each.value.vnet_interface.ip_configuration.subnet_id
    private_ip_address_allocation = each.value.vnet_interface.ip_configuration.private_ip_address_allocation
  }
}

resource "azurerm_windows_virtual_machine" "vm1" {
  for_each = { for vm in var.vm_config : vm.key => vm }
  name                = each.value.name
  resource_group_name = var.rgname
  location            = var.location
  size                = each.value.size
  admin_username      = each.value.admin_username
  admin_password      = each.value.admin_password
  network_interface_ids = [
    azurerm_network_interface.vnet_interface1.id,
  ]
  os_disk {
    caching              = each.value.os_disk_caching
    storage_account_type = each.value.os_disk_storage_account_type
  }
  source_image_reference {
    publisher = each.value.image_publisher
    offer     = each.value.image_offer
    sku       = each.value.image_sku  
    version   = each.value.image_version
  }
}
