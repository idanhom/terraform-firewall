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

  dynamic "security_rule" {
    for_each = var.nsg_rules

    content {
      
    }
  }

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet" "my_subnet" {
  for_each = toset(var.subnet_name)

  resource_group_name = var.resource_group_name

  name                 = each.value
  virtual_network_name = var.vnet_name
  address_prefixes     = [zipmap(var.subnet_name, var.subnet_address_prefix)[each.value]]

  depends_on = [ azurerm_virtual_network.my_vnet ]
}

//resource "azurerm_subnet_network_security_group_association"...

resource "azurerm_subnet" "firewall_subnet" {
  name                 = var.firewall_subnet_name //firewall subnet should always have the name "AzureFirewallSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = var.firewall_subnet_prefix

  depends_on = [ azurerm_virtual_network.my_vnet ]
}



//peering-functionality between vnets?