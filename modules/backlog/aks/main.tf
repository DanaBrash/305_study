terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm    = { source = "hashicorp/azurerm", version = ">= 3.98.0" }
    helm       = { source = "hashicorp/helm", version = ">= 2.11.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = ">= 2.29.0" }
    random     = { source = "hashicorp/random", version = ">= 3.6.0" }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id

}


########################
# Kube / Helm Providers (after AKS exists)
########################
provider "kubernetes" {
  alias                  = "aks"
  host                   = azurerm_kubernetes_cluster.aks.kube_config[0].host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
}

provider "helm" {}


########################
# Variables / Defaults
########################
variable "location" { default = "eastus2" } # Use an AGC-supported region
variable "prefix" { default = "agcaks" }
variable "vnet_cidr" { default = "10.50.0.0/16" }
variable "aks_subnet_cidr" { default = "10.50.1.0/24" }
# AGC association subnet must be /24 or larger and delegated to Microsoft.ServiceNetworking/trafficControllers
variable "agc_subnet_cidr" { default = "10.50.2.0/24" }

# Node pool
variable "system_vm_size" { default = "Standard_B2s" }
variable "system_node_count" { default = 2 }

resource "random_integer" "r" {
  min = 1000
  max = 9999
}

variable "subscription_id" {
  description = "The Azure subscription ID."
  type        = string
  default     = "c1b1f12b-41c7-4fb3-b5ac-02e36ce1331e"
}

variable "tenant_id" {
  description = "The Azure tenant ID."
  type        = string
  default     = "6dd7381d-4ace-410a-b7f3-011a192ebe60"
}
########################
# Resource Group
########################
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg-${random_integer.r.result}"
  location = var.location
}

########################
# Networking
########################
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.vnet_cidr]
}

resource "azurerm_subnet" "aks" {
  name                 = "snet-aks"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.aks_subnet_cidr]
}

# Subnet delegated for AGC Association (must be /24+ and delegated)
resource "azurerm_subnet" "agc" {
  name                 = "snet-agc-assoc"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.agc_subnet_cidr]

  delegation {
    name = "agc-subnet-delegation"
    service_delegation {
      name    = "Microsoft.ServiceNetworking/trafficControllers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

########################
# AKS (Azure CNI + Workload Identity)
########################
resource "azurerm_kubernetes_cluster" "aks" {
  name                              = "${var.prefix}-aks"
  location                          = azurerm_resource_group.rg.location
  resource_group_name               = azurerm_resource_group.rg.name
  dns_prefix                        = "${var.prefix}-dns"
  role_based_access_control_enabled = true
  identity { type = "SystemAssigned" }
  local_account_disabled = false

  # AGC requires Azure CNI (or CNI Overlay) + OIDC/Workload Identity enabled. :contentReference[oaicite:2]{index=2}
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
    service_cidr   = "10.0.0.0/16"
    dns_service_ip = "10.0.0.10"
    outbound_type  = "loadBalancer"
  }

  default_node_pool {
    name                         = "sysnp"
    vm_size                      = var.system_vm_size
    node_count                   = var.system_node_count
    vnet_subnet_id               = azurerm_subnet.aks.id
    only_critical_addons_enabled = true
  }


}

########################
# User-Assigned MI for ALB Controller (AGC)
########################
resource "azurerm_user_assigned_identity" "alb_uami" {
  name                = "${var.prefix}-alb-mi"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Role: AppGw for Containers Configuration Manager (required; includes DataActions) :contentReference[oaicite:3]{index=3}
resource "azurerm_role_assignment" "agc_cfg_mgr" {
  scope              = azurerm_resource_group.rg.id
  role_definition_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/fbc52c3f-28ad-4303-a892-8a056630b8f1"
  principal_id       = azurerm_user_assigned_identity.alb_uami.principal_id
}
data "azurerm_client_config" "current" {}

# Also allow the MI to join the delegated subnet (Network Contributor is simplest) :contentReference[oaicite:4]{index=4}
resource "azurerm_role_assignment" "agc_subnet_join" {
  scope                = azurerm_subnet.agc.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.alb_uami.principal_id
}

########################
# Application Gateway for Containers (parent + child resources)
########################
# Parent AGC resource
resource "azurerm_application_load_balancer" "agc" {
  name                = "${var.prefix}-agc"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

# Frontend (provides the FQDN you CNAME to) :contentReference[oaicite:5]{index=5}
resource "azurerm_application_load_balancer_frontend" "agc_fe" {
  name                         = "fe-01"
  application_load_balancer_id = azurerm_application_load_balancer.agc.id
}

# Association (binds AGC data plane to the delegated subnet) :contentReference[oaicite:6]{index=6}
resource "azurerm_application_load_balancer_subnet_association" "agc_assoc" {
  name                         = "assoc-01"
  application_load_balancer_id = azurerm_application_load_balancer.agc.id
  subnet_id                    = azurerm_subnet.agc.id
}



########################
# Install the ALB Controller (AGC controller) via Helm
########################
# v3: helm_release uses an inline kubernetes connection (or rely on KUBECONFIG)
resource "helm_release" "alb_controller" {
  name       = "alb-controller"
  repository = "oci://mcr.microsoft.com/application-lb/charts"
  chart      = "alb-controller"
  version    = "1.7.9"

  namespace        = "azure-alb-system"
  create_namespace = true


  # v3: list of objects, not set { } blocks
  set = [
    {
      name  = "cluster.enabled"
      value = "true"
    },
    {
      name  = "metricks.enabled"
      value = "true"
    },
    {
      name  = "azure.applicationLoadBalancer.name"
      value = azurerm_application_load_balancer.agc.name
    },
    {
      name  = "albController.podIdentity.clientID"
      value = azurerm_user_assigned_identity.alb_uami.client_id
    }
  ]

  depends_on = [
    azurerm_role_assignment.agc_cfg_mgr,
    azurerm_role_assignment.agc_subnet_join,
    azurerm_application_load_balancer_subnet_association.agc_assoc
  ]
}

########################
# Outputs
########################
output "resource_group" { value = azurerm_resource_group.rg.name }
output "aks_name" { value = azurerm_kubernetes_cluster.aks.name }
output "agc_id" { value = azurerm_application_load_balancer.agc.id }
output "agc_frontend_fqdn" { value = azurerm_application_load_balancer_frontend.agc_fe.fully_qualified_domain_name }
output "get_credentials_command" {
  value = "az aks get-credentials -g ${azurerm_resource_group.rg.name} -n ${azurerm_kubernetes_cluster.aks.name} --overwrite-existing"
}
