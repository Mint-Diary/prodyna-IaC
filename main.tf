data "azurerm_resource_group" "main" {
  name = "RG-Demid-Krom"
}

module "network" {
  source             = "./modules/network"
  rg_name            = data.azurerm_resource_group.main.name
  location           = data.azurerm_resource_group.main.location
  vnet_address_space = var.vnet_address_space
}

module "security" {
  source    = "./modules/security"
  rg_name   = data.azurerm_resource_group.main.name
  location  = data.azurerm_resource_group.main.location
  subnet_id = module.network.pe_subnet_id
}

module "storage" {
  source    = "./modules/storage"
  rg_name   = data.azurerm_resource_group.main.name
  location  = data.azurerm_resource_group.main.location
  subnet_id = module.network.pe_subnet_id
}

module "aks" {
  source    = "./modules/aks"
  rg_name   = data.azurerm_resource_group.main.name
  location  = data.azurerm_resource_group.main.location
  subnet_id = module.network.aks_subnet_id
}