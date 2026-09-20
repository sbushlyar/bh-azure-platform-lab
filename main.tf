terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
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
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
}
resource "azurerm_subnet" "lab" {
  name                 = "snet-app"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.lab.name
  address_prefixes     = ["10.10.1.0/24"]
}
resource "azurerm_network_security_group" "lab" {
  name                = "nsg-app"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
}