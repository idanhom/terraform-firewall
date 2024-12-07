# review before begin
# https://chatgpt.com/g/g-pDLabuKvD-terraform-guide/c/67489a47-2648-800b-99b3-d8fdc7becfc7


# note: implement the afw map variable to make it like var.vnets (no for_each though...)

resource "azurerm_virtual_network" "firewall_vnet" {

  resource_group_name = var.resource_group_name
  location            = var.location

  name          = var.afw.firewall_vnet_name   #var.firewall_vnet_name
  address_space = var.afw.firewall_vnet_prefix #var.firewall_vnet_prefix
}

resource "azurerm_subnet" "firewall_subnet" {

  resource_group_name = var.resource_group_name

  name                 = var.afw.firewall_subnet_name #var.firewall_subnet_name
  virtual_network_name = var.afw.firewall_vnet_name   #var.firewall_vnet_name

  address_prefixes = var.afw.firewall_subnet_prefix #var.firewall_subnet_prefix

  depends_on = [azurerm_virtual_network.firewall_vnet]
}

resource "azurerm_public_ip" "firewall_ip" {

  name                = var.afw.firewall_ip_name #var.firewall_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_firewall" "firewall" {
  name                = var.afw.firewall_name #var.firewall_name
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