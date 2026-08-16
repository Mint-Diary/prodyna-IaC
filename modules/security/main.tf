variable "rg_name" {}
variable "location" {}
variable "subnet_id" {}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                        = "kv-prodyna-${substr(uuid(), 0, 6)}"
  location                    = var.location
  resource_group_name         = var.rg_name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  enable_rbac_authorization   = true
}

resource "azurerm_private_endpoint" "kv_pe" {
  name                = "pe-keyvault"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "kv-privatelink"
    private_connection_resource_id = azurerm_key_vault.kv.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }
}