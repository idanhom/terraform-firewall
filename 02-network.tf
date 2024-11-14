resource "azurerm_virtual_network" "my_vnet" {
  name                = var.vnet_name
  address_space       = var.vnet_prefix
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "firewall_subnet" {
  name                 = "AzureFirewallSubnet" //firewall subnet should always have this name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.my_vnet.name
  address_prefixes     = var.firewall_subnet_prefix
}

resource "azurerm_public_ip" "firewall_ip" {
  name                = var.firewall_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard" //public ip 
  lifecycle {
    create_before_destroy = true
  }
}
