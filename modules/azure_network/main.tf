resource "azurerm_virtual_network" "my_vnet" {
  resource_group_name = var.resource_group_name
  location            = var.location
  name                = var.vnet_name
  address_space       = var.vnet_prefix
}

resource "azurerm_subnet" "my_subnet" {
  for_each = toset(var.subnet_name)

  resource_group_name = var.resource_group_name

  name                 = each.value
  virtual_network_name = var.vnet_name
  address_prefixes     = [zipmap(var.subnet_name, var.subnet_address_prefix)[each.value]]

  depends_on = [ azurerm_virtual_network.my_vnet ]
}




resource "azurerm_subnet" "firewall_subnet" {
  name                 = var.firewall_subnet_name //firewall subnet should always have the name "AzureFirewallSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = var.firewall_subnet_prefix

  depends_on = [ azurerm_virtual_network.my_vnet ]
}

//more subnet... for_each relevant to vms?

//nsg...

//peering-functionality between vnets?