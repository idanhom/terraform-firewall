resource "azurerm_virtual_network" "my_vnet" {
  name                = var.vnet_name
  address_space       = var.vnet_prefix
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "my_subnet" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.my_vnet.name
  address_prefixes     = var.subnet_address_prefix
}

resource "azurerm_subnet" "firewall_subnet" {
  name                 = "AzureFirewallSubnet" //firewall subnet should always have this name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.my_vnet.name
  address_prefixes     = var.firewall_subnet_prefix
}

//more subnet... for_each relevant to vms?

//nsg...

//peering-functionality between vnets?