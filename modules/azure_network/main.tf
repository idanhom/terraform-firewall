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
  sku_name            = "AZFW_Hub"
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

output "firewall_private_ip" {
  value = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
}


#note: since I'm removing vWAN architecture, remove the virtual_hub too.
/*   virtual_hub {
    virtual_hub_id = azurerm_virtual_hub.secure_hub.id
    public_ip_count = 1 
    # when there are optional arguments, like "public_ip_count" that has 1 as default, should these be added?
  }
}

########### Virtual WAN and Virtual Hub config

# Todo (connected to vWAN (which is overkill for what I want to do...)):
# virtual_hub_routing_intent

# virtual hub connnections -> enable default routing 
# (^default hub connection)

# monitoring (diagnostics) solution is done in the firewall itself
# target resouce id -> firewall id -> specify audit settings (which category of logs to import -> deploy diagnostics manually, import, check state, reverse configure as terraform)
# Manish will check with some terraform infra guy and reconnect with me


# -------------------------------------------------------------

# resource "azurerm_virtual_wan" "secure_wan" {
#   name                = "secure-virtual-wan"
#   resource_group_name = var.resource_group_name
#   location            = var.location
# }

# resource "azurerm_virtual_hub" "secure_hub" {
#   name                = "secure-virtual-hub"
#   resource_group_name = var.resource_group_name
#   location            = var.location
#   virtual_wan_id      = azurerm_virtual_wan.secure_wan.id
#   sku                 = "Standard" # Standard needed for AFW
#   address_prefix      = "10.3.0.0/23"
# }

# resource "azurerm_virtual_hub_connection" "vnet_connections" {
#   for_each                  = var.vnets
#   name                      = "connection-${each.key}"
#   virtual_hub_id            = azurerm_virtual_hub.secure_hub.id
#   remote_virtual_network_id = azurerm_virtual_network.my_vnet[each.key].id
#   internet_security_enabled = true 
#   # internet_security to make vnet pass through AFW
#   depends_on = [azurerm_virtual_hub.secure_hub, azurerm_firewall.firewall]
# }

# resource "azurerm_virtual_hub_route_table" "vnet_route_table" { # rename it from vnet_route_table to something that has both capabilities
#   name           = var.firewall_route_table.name
#   virtual_hub_id = azurerm_virtual_hub.secure_hub.id

#   route {
#     name              = "internet-traffic"
#     destinations_type = var.firewall_route_table.internet_traffic.destinations_type
#     destinations      = var.firewall_route_table.internet_traffic.destinations
#     next_hop_type     = var.firewall_route_table.internet_traffic.next_hop_type
#     next_hop          = azurerm_firewall.firewall.id
#   }

#   # VNet to VNet routes
#   dynamic "route" {
#     for_each = var.vnets
#     content {
#       name              = "to-${route.key}"
#       destinations_type = var.firewall_route_table.vnet_to_vnet.destinations_type
#       destinations      = route.value.vnet_prefix
#       next_hop_type     = var.firewall_route_table.vnet_to_vnet.next_hop_type
#       next_hop          = azurerm_virtual_hub_connection.vnet_connections[route.key].id
#     }
#   }
# }







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