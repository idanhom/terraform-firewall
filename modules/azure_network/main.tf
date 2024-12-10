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

# review before begin
# https://chatgpt.com/g/g-pDLabuKvD-terraform-guide/c/67489a47-2648-800b-99b3-d8fdc7becfc7



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
  address_prefixes = var.afw.firewall_subnet_prefix 
  
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

resource "azurerm_virtual_hub" "secure_hub" {
  name                = "secure-virtual-hub"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku = "Standard"
  address_prefix      = "10.3.0.0/23"
}

resource "azurerm_virtual_hub_connection" "vnet_connections" {
  for_each = var.vnets
  name                      = "connection-${each.key}"
  virtual_hub_id            = azurerm_virtual_hub.secure_hub.id
  remote_virtual_network_id = azurerm_virtual_network.my_vnet[each.key].id
}


# ongoing fixing
# https://chatgpt.com/g/g-pDLabuKvD-terraform-guide/c/6756b04f-9f34-800b-9bd1-0b425c147697
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_hub_route_table
resource "azurerm_virtual_hub_route_table" "vnet_route_table" {
  name           = "vnet_route_table"
  virtual_hub_id = azurerm_virtual_hub.secure_hub.id

  route {
    name              = "internet-traffic"
    destinations_type = "0.0.0.0/0"
    destinations      = ["10.0.0.0/16"]
    next_hop_type     = "ResourceId"
    next_hop          = azurerm_firewall.firewall.id
  } 

  # VNet to VNet routes

  dynamic "route" {
    for_each = var.vnets
    
    name              = "to-${route.key}"
    destinations      = route.value.vnet_prefix[0]
    next_hop_type     = "ResourceId"
    next_hop          = azurerm_firewall.firewall.id
  } 

  }
  

}