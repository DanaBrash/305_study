module "virtual_machine_windows" {
  source = "./modules/virtual_machine_windows"
  location            = var.location
  subscription_id     = var.subscription_id
  tenant_id           = var.tenant_id
}
