# Networking 
# What happens: two vnets and subnets are created,
#               based on map of objects 'vnets' in .tfvars  
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
  virtual_network_name = azurerm_virtual_network.my_vnet[each.key].name
  address_prefixes     = each.value.subnet_prefix

  service_endpoints = ["Microsoft.Storage"]

  depends_on = [azurerm_virtual_network.my_vnet]
}



#---------------------------------

# AFW (vnet, subnet, ip, afw)
resource "azurerm_virtual_network" "firewall_vnet" {
  resource_group_name = var.resource_group_name
  location            = var.location
  name                = var.afw.firewall_vnet_name
  address_space       = var.afw.firewall_vnet_prefix
}

resource "azurerm_subnet" "firewall_subnet" {
  resource_group_name  = var.resource_group_name
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

# -------------------------


# AFW route table for vnet1 and vnet2 to AFW
resource "azurerm_route_table" "firewall_route_table" {
  name                = "firewall_route_table"
  location            = var.location
  resource_group_name = var.resource_group_name

  ## Routing vnet1 to firewall
  route {
    name                   = var.vnet_route_table.vnet1.internet_traffic.name
    address_prefix         = var.vnet_route_table.vnet1.internet_traffic.address_prefix
    next_hop_type          = var.vnet_route_table.vnet1.internet_traffic.next_hop_type
    next_hop_in_ip_address = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
  }

  ## Routing vnet2 to firewall
  route {
    name                   = var.vnet_route_table.vnet2.internet_traffic.name
    address_prefix         = var.vnet_route_table.vnet2.internet_traffic.address_prefix
    next_hop_type          = var.vnet_route_table.vnet2.internet_traffic.next_hop_type
    next_hop_in_ip_address = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
  }

  depends_on = [azurerm_firewall.firewall]
}


resource "azurerm_subnet_route_table_association" "subnet_and_route_table_association" {
  for_each       = azurerm_subnet.my_subnet
  subnet_id      = each.value.id
  route_table_id = azurerm_route_table.firewall_route_table.id
}
# -------------------------------


# Bydirectional peering between VNets and AFW
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

# ----------------------------------

# Firewall rule collections#

## Enables compute in vnet1 and vnet2 to communicate directly
resource "azurerm_firewall_network_rule_collection" "inter_vm_traffic" {
  name                = "inter_vm_traffic"
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = var.resource_group_name
  priority            = 100
  action              = "Allow"

  rule {
    name                  = "allow-inter-vnet"
    source_addresses      = ["10.0.0.0/16", "10.1.0.0/16"] # this can be made nicer and dynamic? take the subnet address prefix[0] for vnet1 and vnet2?
    destination_addresses = ["10.0.0.0/16", "10.1.0.0/16"] # this can be made nicer and dynamic? take the subnet address prefix[0] for vnet1 and vnet2?
    destination_ports     = ["*"]
    protocols             = ["TCP", "UDP", "ICMP"]
  }
}

## Allows compute to resolve domain names via Azure DNS (important for resolving the *storage-account*.privatelink... url)
resource "azurerm_firewall_network_rule_collection" "dns_allow" {
  name                = "allow_dns"
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = var.resource_group_name
  priority            = 200
  action              = "Allow"

  rule {
    name                  = "allow-dns"
    source_addresses      = ["10.0.0.0/16", "10.1.0.0/16"]
    destination_addresses = ["168.63.129.16"] //Enables VMs and services to communicate with Azure DNS for internal name resolution
    destination_ports     = ["53"] //port for DNS queries
    protocols             = ["UDP", "TCP"]
  }
}

## Restricts access to Azure Storage based on vnet IP ranges
resource "azurerm_firewall_network_rule_collection" "allow_azure_storage" {
  name                = "allow_azure_storage"
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = var.resource_group_name
  priority            = 300
  action              = "Allow"

  ### Rule for VM1 in vnet1 to access the storage account
  rule {
    name                  = "allow-blob-storage-vnet1"
    source_addresses      = ["10.0.0.0/16"] # Only include the subnet range for vnet1
    destination_addresses = ["Storage"]
    destination_ports     = ["443"]
    protocols             = ["TCP"]
  }

  ### Rule for VM2 in vnet2 to access the storage account
  rule {
    name                  = "allow-blob-storage-vnet2"
    source_addresses      = ["10.1.0.0/16"] # Only include the subnet range for vnet2
    destination_addresses = ["Storage"]
    destination_ports     = ["443"]
    protocols             = ["TCP"]
  }
  
  //note, when creating self-hosted runner, also allow access from it to storage account
}


## Allows inbound traffic to VMs via the firewall for web server
resource "azurerm_firewall_nat_rule_collection" "nginx_inbound_dnat" {
  name                = "nginx_inbound_dnat"
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = var.resource_group_name
  priority            = 400
  action              = "Dnat"

  rule {
    name                  = "vm1_http"
    description           = "Route HTTP traffic for VM1"
    source_addresses      = ["*"]
    destination_addresses = [azurerm_public_ip.firewall_ip.ip_address]
    destination_ports     = ["8080"]
    protocols             = ["TCP"]
    translated_address    = var.vm_private_ip["vnet1"]
    translated_port       = "80"
  }

  rule {
    name                  = "vm2_http"
    description           = "Route HTTP traffic for VM2"
    source_addresses      = ["*"]
    destination_addresses = [azurerm_public_ip.firewall_ip.ip_address]
    destination_ports     = ["8081"]
    protocols             = ["TCP"]
    translated_address    = var.vm_private_ip["vnet2"]
    translated_port       = "80"
  }
}

## Allows secure outbound internet access for VMs in vnet1 and vnet2
resource "azurerm_firewall_network_rule_collection" "outbound_internet" {
  name                = "allow_outbound_internet"
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = var.resource_group_name
  priority            = 500
  action              = "Allow"

  rule {
    name                  = "allow-vm-outbound-internet"
    source_addresses      = ["10.0.0.0/16", "10.1.0.0/16"]
    destination_addresses = ["*"]
    destination_ports     = ["80", "443"]
    protocols             = ["TCP"]
  }
}