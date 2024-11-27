resource "azurerm_virtual_network" "my_vnet" {
  for_each = var.vnets
  
  resource_group_name = var.resource_group_name
  location            = var.location
  name                = each.value.vnet_name
  address_space       = each.value.vnet_prefix

  depends_on = [ var.resource_group_name ]
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
  for_each = var.vnets

  resource_group_name = var.resource_group_name

  name                 = each.value.subnet_name
  virtual_network_name = each.value.vnet_name
  address_prefixes     = [each.value.subnet_prefix]

  depends_on = [azurerm_virtual_network.my_vnet]
}

https://chatgpt.com/g/g-duAEb2Su1-terraform-transcript-transformer/c/6744738d-5b94-800b-a4b0-2b450b043e78

resource "azurerm_subnet_network_security_group_association" "nsg_to_subnet_association" {
  for_each = azurerm_subnet.my_subnet

  subnet_id                 = each.value.id
  network_security_group_id = azurerm_network_security_group.my_nsg.id
}

resource "azurerm_subnet" "firewall_subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = var.firewall_subnet_prefix

  depends_on = [azurerm_virtual_network.my_vnet]
}



//peering-functionality between vnets?