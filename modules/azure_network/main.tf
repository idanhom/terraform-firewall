resource "azurerm_virtual_network" "my_vnet" {
  resource_group_name = var.resource_group_name
  location            = var.location
  name                = var.vnet_name
  address_space       = var.vnet_prefix
}

resource "azurerm_subnet" "my_subnet" {
  resource_group_name = var.resource_group_name

  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  address_prefixes     = var.subnet_address_prefix
}

resource "azurerm_subnet" "firewall_subnet" {
  name                 = var.firewall_subnet_name //firewall subnet should always have the name "AzureFirewallSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = var.firewall_subnet_prefix
}

//more subnet... for_each relevant to vms?

//nsg...

//peering-functionality between vnets?