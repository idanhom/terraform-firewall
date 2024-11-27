resource "azurerm_virtual_network" "firewall_vnet" {
  
  resource_group_name = var.resource_group_name
  location = var.location

  name = var.firewall_vnet_name
  address_space = var.firewall_vnet_prefix
}

resource "azurerm_subnet" "firewall_subnet" {

  resource_group_name  = var.resource_group_name

  name                 = var.firewall_subnet_name
  virtual_network_name = var.firewall_vnet_name

  address_prefixes     = var.firewall_subnet_prefix

  depends_on = [azurerm_virtual_network.firewall_vnet]
}

resource "azurerm_public_ip" "firewall_ip" {

  name                = var.firewall_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_firewall" "firewall" {
  name                = var.firewall_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.firewall_subnet.id 
    public_ip_address_id = azurerm_public_ip.firewall_ip.id 
  }
}