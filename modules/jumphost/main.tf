resource "azurerm_public_ip" "jumphost_pip" {
  name                = "pip-jumphost"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "jumphost_nic" {
  name                = "nic-jumphost"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jumphost_pip.id
  }
}

resource "azurerm_linux_virtual_machine" "jumphost" {
  name                = "vm-jumphost"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B2s_v2"
  admin_username      = "adminuser"

  network_interface_ids = [
    azurerm_network_interface.jumphost_nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}