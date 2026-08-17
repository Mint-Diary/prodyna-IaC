data "azurerm_resource_group" "main" {
  name = "RG-Demid-Krom"
}

resource "tls_private_key" "jumphost_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
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

module "jumphost" {
  source              = "./modules/jumphost"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location

  subnet_id           = module.network.pe_subnet_id

  ssh_public_key      = tls_private_key.jumphost_ssh.public_key_openssh
}

# Ansible

# save the private-SSH-Key localy so Ansible can use it
resource "local_file" "ansible_ssh_key" {
  content         = tls_private_key.jumphost_ssh.private_key_pem
  filename        = "${path.module}/ansible/jumphost_key.pem"
  file_permission = "0600"
}

# ip log
output "jumphost_public_ip" {
  value       = module.jumphost.public_ip
  description = "Nutze diese IP fuer Ansible!"
}