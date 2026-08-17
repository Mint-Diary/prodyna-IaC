variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure Region"
}

variable "subnet_id" {
  type        = string
  description = "ID of the subnet where the jumphost will be deployed"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH Public Key for the Jumphost admin user"
}