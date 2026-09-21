terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-bh-platform-lab"
    storage_account_name = "tfstatebh80857"
    container_name       = "tfstate"
    key                  = "bh-platform-lab.tfstate"
    use_azuread_auth     = true
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "lab" {
  name     = "rg-bh-platform-lab"
  location = "East US"
}

resource "azurerm_virtual_network" "lab" {
  name                = "vnet-bh-platform-lab"
  address_space       = ["10.10.0.0/16"]
  location = "West US 2"
  resource_group_name = azurerm_resource_group.lab.name
}

resource "azurerm_subnet" "lab" {
  name                 = "snet-app"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.lab.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_public_ip" "lab" {
  name                = "pip-bh-platform-vm01"
  location            = "West US 2"
  resource_group_name = azurerm_resource_group.lab.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "lab" {
  name                = "nsg-app"
  location            = "West US 2"
  resource_group_name = azurerm_resource_group.lab.name

  security_rule {
    name                       = "Allow-SSH-From-Home"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "67.243.198.91/32"
    destination_address_prefix = "*"
  }
}
resource "azurerm_subnet_network_security_group_association" "lab" {
  subnet_id                 = azurerm_subnet.lab.id
  network_security_group_id = azurerm_network_security_group.lab.id
}
resource "azurerm_network_interface" "lab" {
  name                = "nic-bh-platform-vm01"
  location = "West US 2"
  resource_group_name = azurerm_resource_group.lab.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.lab.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.lab.id
  }
}
resource "azurerm_linux_virtual_machine" "lab" {
  name                = "vm-bh-platform-01"
  resource_group_name = azurerm_resource_group.lab.name
  location = "West US 2"
  size                = "Standard_B2ats_v2"
  admin_username      = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.lab.id
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHTs1rQ/8VLBwMh0+ln8gbVFnQLCyYTmRnRBQR7y2Iy9 sbush@REMCON"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}