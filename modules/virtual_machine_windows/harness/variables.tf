
variable "subscription_id" {
  description = "The Azure subscription ID."
  type        = string
}

variable "tenant_id" {
  description = "The Azure tenant ID."
  type        = string
}

variable "vm_config" {
  description = "Configuration map for the virtual machine."
  type = map(object({
    name                         = string
    size                         = string
    admin_username               = string
    admin_password               = string

    os_disk_caching              = string
    os_disk_storage_account_type = string

    vnet_interface = map(object({
      name                          = string
    
      ip_configuration = list(object({
        name                          = string
        subnet_id                     = string
        private_ip_address_allocation = string
      }))
    }))

    image_publisher = string
    image_offer     = string
    image_sku       = string
    image_version   = string
  }))
  default = {
    vm1 = {
      name                         = module.naming.virtual_machine.name
      size                         = "Standard_B2ms"
      admin_username               = "adminuser"
      admin_password               = "P@ssw0rd1234!"

      os_disk_caching              = "ReadWrite"
      os_disk_storage_account_type = "Standard_LRS"

      vnet_interface = {
        v_int1 = {
          name                          = "vnet_interface1"
          
          ip_configuration = [{
            name                          = "ipconfig1"
            subnet_id                     = ""
            private_ip_address_allocation = "Dynamic"
          }]
        }
      }
      image_publisher = "MicrosoftWindowsServer"
      image_offer     = "WindowsServer"
      image_sku       = "2019-Datacenter"
      image_version   = "latest"
    }
  }
}
