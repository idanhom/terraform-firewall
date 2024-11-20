resource "azurerm_virtual_network" "my_vnet" {
  resource_group_name = var.resource_group_name
  location            = var.location
  name                = var.vnet_name
  address_space       = var.vnet_prefix
}

//azurerm_network_security_group...
//https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group
resource "azurerm_network_security_group" "my_nsg" {
  name                = "nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  depends_on          = [azurerm_virtual_network.my_vnet]

  dynamic "security_rule" {
    for_each = var.nsg_rules

    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_port_range
      destination_address_prefix = security_rule.value.destination_port_range
    }
  }
}

resource "azurerm_subnet" "my_subnet" {
  for_each = toset(var.subnet_name)

  resource_group_name = var.resource_group_name

  name                 = each.value
  virtual_network_name = var.vnet_name
  address_prefixes     = [zipmap(var.subnet_name, var.subnet_address_prefix)[each.value]]

  depends_on = [azurerm_virtual_network.my_vnet]
}

resource "azurerm_subnet_network_security_group_association" "nsg_to_subnet_association" {
  for_each                  = azurerm_subnet.my_subnet

  subnet_id                 = each.value.id
  network_security_group_id = azurerm_network_security_group.my_nsg.id
}

resource "azurerm_subnet" "firewall_subnet" {
  name                 = "AzureFirewallSubnet" // var.firewall_subnet_name //firewall subnet should always have the name "AzureFirewallSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = var.firewall_subnet_prefix

  depends_on = [azurerm_virtual_network.my_vnet]
}



//peering-functionality between vnets?