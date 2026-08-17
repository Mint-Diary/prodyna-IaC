output "public_ip" {
  value       = azurerm_linux_virtual_machine.jumphost.public_ip_address
  description = "public ip of the jumphost"
}