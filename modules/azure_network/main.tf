#Networking for VM's
resource "azurerm_virtual_network" "my_vnet" {
  for_each = var.vnets

  resource_group_name = var.resource_group_name
  location            = var.location
  name                = each.value.vnet_name
  address_space       = each.value.vnet_prefix
}
#  Error: deleting Virtual Network (Subscription: "3e00befb-2b03-4b60-b8a0-faf06ad28b5e"
# │ Resource Group Name: "rg_project1"
# │ Virtual Network Name: "vnet1"): performing Delete: unexpected status 400 (400 Bad Request) with error: InUseSubnetCannotBeDeleted: Subnet subnet1 is in use by /subscriptions/3e00befb-2b03-4b60-b8a0-faf06ad28b5e/resourceGroups/RG_PROJECT1/providers/Microsoft.Network/networkInterfaces/NIC1/ipConfigurations/INTERNAL and cannot be deleted. In order to delete the subnet, delete all the resources within the subnet. See aka.ms/deletesubnet.




resource "azurerm_subnet" "my_subnet" {
  for_each = var.vnets

  resource_group_name  = var.resource_group_name
  name                 = each.value.subnet_name
  virtual_network_name = each.value.vnet_name
  address_prefixes     = each.value.subnet_prefix

  depends_on = [azurerm_virtual_network.my_vnet]
}


# Commented out NSG to troubleshoot connectivity to VMs. Also, AFW serves same purpose?

/* resource "azurerm_network_security_group" "my_nsg" {
  name                = "nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  depends_on          = [azurerm_virtual_network.my_vnet]

  dynamic "security_rule" {
    for_each = var.nsg_rules


    # here, add single rule, allow all 80 to and from... or maybe in .tfvars
    # also allow inbound 22
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
} */ 

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




### obs: needed to add DNS allow here????

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
  for_each                  = var.vnets
  name                      = "peer-hub-to-${each.key}"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.firewall_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.my_vnet[each.key].id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  for_each                  = var.vnets
  name                      = "peer-spoke-to-${each.key}"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.my_vnet[each.key].name
  remote_virtual_network_id = azurerm_virtual_network.firewall_vnet.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}


#################


#firewall rule collections

resource "azurerm_firewall_network_rule_collection" "inter_vm_traffic" {
  name                = "inter_vm_traffic"
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = var.resource_group_name
  priority            = 100
  action              = "Allow"

  rule {
    name = "allow-inter-vnet"
  source_addresses = ["10.0.0.0/16", "10.1.0.0/16"] # this can be made nicer and dynamic? take the subnet address prefix[0] for vnet1 and vnet2?
    destination_addresses = ["10.0.0.0/16", "10.1.0.0/16"] # this can be made nicer and dynamic? take the subnet address prefix[0] for vnet1 and vnet2?
    destination_ports = ["*"]
    protocols = ["TCP", "UDP", "ICMP"]
  }
}

# Unneccessary because am using Bastion for SSH. 
/* resource "azurerm_firewall_nat_rule_collection" "internet_to_vms" {
  name                = "internet-to-vms"
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = var.resource_group_name
  priority            = 200
  action              = "Dnat"

  dynamic "rule" {
    for_each = var.vnets # Assumes `vnets` is a map of VMs, similar to your dev.tfvars

    content {
      name                  = "nat-internet-to-${rule.value.vnet_name}"  # Unique name for each rule
      source_addresses      = ["*"]                                     # Allow from all external sources
      destination_ports     = ["22"]                       # Ports to allow (e.g., SSH, HTTP, HTTPS)
      destination_addresses = [azurerm_public_ip.firewall_ip.ip_address] # Firewall's public IP
      translated_address    = var.vm_private_ip[rule.key] # Map to VM's private IP
      translated_port       = 22                                        # Target VM port (22 in this case for SSH)
      protocols             = ["TCP"]                                   # Protocol to allow
    }
  }
} */


# Firewall Network Rule Collection for Outbound Internet Access
resource "azurerm_firewall_network_rule_collection" "outbound_internet" {
  name                = "allow_outbound_internet"
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = var.resource_group_name
  priority            = 300
  action              = "Allow"

  rule {
    name                 = "allow-vm-outbound-internet"
    source_addresses     = ["10.0.0.0/16", "10.1.0.0/16"] 
    destination_addresses = ["*"]                      
    destination_ports    = ["80", "443"]                 
    protocols            = ["TCP"]                      
  }
}








# https://learn.microsoft.com/en-us/azure/architecture/networking/architecture/hub-spoke?tabs=cli
