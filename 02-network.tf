resource "azurerm_virtual_network" "my-vnet" {
  name                = var.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg-project.location
  resource_group_name = azurerm_resource_group.rg-project.name
}

resource "azurerm_subnet" "firewall-subnet" {
  name                 = var.firewall_subnet_name
  resource_group_name  = azurerm_resource_group.rg-project.name
  virtual_network_name = azurerm_virtual_network.my-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "firewall-ip" {
  name                = var.firewall_ip_name
  location            = azurerm_resource_group.rg-project.location
  resource_group_name = azurerm_resource_group.rg-project.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
