#Networking for VM's
resource "azurerm_virtual_network" "my_vnet" {
  for_each = var.vnets

  resource_group_name = var.resource_group_name
  location            = var.location
  name                = each.value.vnet_name
  address_space       = each.value.vnet_prefix
}

resource "azurerm_subnet" "my_subnet" {
  for_each = var.vnets

  resource_group_name  = var.resource_group_name
  name                 = each.value.subnet_name
  virtual_network_name = each.value.vnet_name
  address_prefixes     = each.value.subnet_prefix

  depends_on = [azurerm_virtual_network.my_vnet]
}

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

resource "azurerm_subnet_network_security_group_association" "nsg_to_subnet_association" {
  for_each = azurerm_subnet.my_subnet

  subnet_id                 = each.value.id
  network_security_group_id = azurerm_network_security_group.my_nsg.id
}

#########################

# Firewall resources
resource "azurerm_virtual_network" "firewall_vnet" {

  resource_group_name = var.resource_group_name
  location            = var.location

  name          = var.afw.firewall_vnet_name
  address_space = var.afw.firewall_vnet_prefix
}

resource "azurerm_subnet" "firewall_subnet" {

  resource_group_name = var.resource_group_name

  name                 = var.afw.firewall_subnet_name
  virtual_network_name = var.afw.firewall_vnet_name
  address_prefixes     = var.afw.firewall_subnet_prefix

  depends_on = [azurerm_virtual_network.firewall_vnet]
}

resource "azurerm_public_ip" "firewall_ip" {

  name                = var.afw.firewall_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_firewall" "firewall" {
  name                = var.afw.firewall_name
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

resource "azurerm_route_table" "firewall_route_table" {
  depends_on = [azurerm_firewall.firewall]

  name                = "firewall_route_table"
  location            = var.location
  resource_group_name = var.resource_group_name


  # Routing vnet1 to firewall
  route {
    name                   = var.vnet_route_table.vnet1.internet_traffic.name
    address_prefix         = var.vnet_route_table.vnet1.internet_traffic.address_prefix
    next_hop_type          = var.vnet_route_table.vnet1.internet_traffic.next_hop_type
    next_hop_in_ip_address = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
  }

  route {
    name                   = var.vnet_route_table.vnet2.internet_traffic.name
    address_prefix         = var.vnet_route_table.vnet2.internet_traffic.address_prefix
    next_hop_type          = var.vnet_route_table.vnet2.internet_traffic.next_hop_type
    next_hop_in_ip_address = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
  }
}


resource "azurerm_subnet_route_table_association" "subnet_and_route_table_association" {
  for_each       = azurerm_subnet.my_subnet
  subnet_id      = each.value.id
  route_table_id = azurerm_route_table.firewall_route_table.id
}


################
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  for_each = var.vnets
  name                      = "peer-hub-to-${each.key}"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.firewall_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.my_vnet[each.key].id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  for_each = var.vnets
  name                      = "peer-spoke-to-${each.key}"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.my_vnet[each.key].name
  remote_virtual_network_id = azurerm_virtual_network.firewall_vnet.idhttps://portal.azure.com/#@pson93hotmail.onmicrosoft.com/resource/subscriptions/3e00befb-2b03-4b60-b8a0-faf06ad28b5e/resourceGroups/rg_project1/overview
  
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}












# Jimmys kommentar:


/* hub and spoke -> brandvägg är hub och alla andra vnet är spokes.

hub är connectitivty landing zone. allt som berör nätverksdelar (enterprise scale), ddos protection, dns, allt är i connectivity landing zone. för allt annat -> får vnet med route tables och allt pekar mot branväggen.

peera vnet mot brandväggens nätverk.

alltså för mig, ta bort Wvan, all traffik är next-hop -> brandvägg.

hopp mellan vnet och 


"hubben är där vnet för brandväggen ligger i"
-------------

https://learn.microsoft.com/en-us/azure/architecture/networking/architecture/hub-spoke?tabs=cli


 */