# Terraform
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.40.0"
    }
  }
}

#Azure provider
provider "azurerm" {
  features {}
}


#Create virtual network
resource "azurerm_virtual_network" "vnet" {
    name                = "vnet-dev-${var.location}-001"
    address_space       = var.vnet_address_space
    location            = var.location
    resource_group_name = "cal-1271-d6c"
}

# Create subnet
resource "azurerm_subnet" "subnet" {
  name                 = "snet-dev-${var.location}-001 "
  resource_group_name  = "cal-1271-d6c"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes       = var.snet_address_space
}


# Create network interface
resource "azurerm_network_interface" "nic" {
  name                      = "nic-01-${var.servername}-dev-001 "
  location                  = var.location
  resource_group_name       = "cal-1271-d6c"

  ip_configuration {
    name                          = "niccfg-${var.servername}"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "dynamic"
  }
}

# Create virtual machine
resource "azurerm_virtual_machine" "vm" {
  name                  = var.servername
  location              = var.location
  resource_group_name   = "cal-1271-d6c"
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_B1s"

  storage_os_disk {
    name              = "stvm${var.servername}os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = lookup(var.managed_disk_type, var.location, "Standard_LRS")
  }

  storage_image_reference {
    publisher = var.os.publisher
    offer     = var.os.offer
    sku       = var.os.sku
    version   = var.os.version
  }

  os_profile {
    computer_name  = var.servername
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}