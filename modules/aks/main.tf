variable "rg_name" {}
variable "location" {}
variable "subnet_id" {}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-prodyna-dev"
  location            = var.location
  resource_group_name = var.rg_name
  dns_prefix          = "prodynaaks"

  default_node_pool {
    name           = "default"
    node_count     = 1
    vm_size        = "Standard_B2s_v2"
    vnet_subnet_id = var.subnet_id
  }

  identity {
    type = "SystemAssigned"
  }

  # prevents vnet ip overlap
  network_profile {
    network_plugin = "kubenet"
    service_cidr   = "192.168.0.0/16"
    dns_service_ip = "192.168.0.10"
    pod_cidr       = "172.16.0.0/16"
  }
}