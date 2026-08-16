variable "rg_name" {}
variable "location" {}
variable "subnet_id" {}

resource "azurerm_storage_account" "sa" {
  name                     = "stprodyna${substr(uuid(), 0, 6)}"
  resource_group_name      = var.rg_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_private_endpoint" "sa_pe" {
  name                = "pe-storage"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "sa-privatelink"
    private_connection_resource_id = azurerm_storage_account.sa.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
}