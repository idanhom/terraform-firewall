variable "resource_group_name" {
  description = "Name of the resource group to create"
  type        = string
}

variable "location" {
  description = "Location of the resources"
  type        = string
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "vnet_prefix" {
  description = "CIDR for the virtual network"
  type        = list(string)
}

variable "subnet_name" {
  description = "name of subnet"
  type        = list(string)
}

variable "subnet_address_prefix" {
  description = "CIDR block for subnet"
  type        = list(string)
}

variable "firewall_subnet_prefix" {
  description = "CIDR for the firewall subnet prefix"
  type        = list(string)
}

variable "firewall_subnet_name" {
  description = "name of firewall subnet (do not change)"
  type        = string
}

variable "firewall_name" {
  description = "name of firewall"
  type        = string
}

variable "firewall_ip_name" {
  description = "name of ip for firewall"
  type        = string
}

# variable "nsg_rule_name" {
#   description = "name for nsg rule"
#   type = string
# }


variable "nsg_rules" {
  description = "rules for nsg"
  type = list(object({
    name                       = string
    priority                   = 100
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))

  default = [ {

  //Standard inbound
    name                       = "AllowVNetInBound"
    priority                   = 65000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  },
  {
    name                       = "AllowAzureLoadBalancerInBound"
    priority                   = 65001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "AzureLoadBalancer"
  },
  {
    name                       = "DenyAllInbound"
    priority                   = 65500
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "Internet"
  
  //Standard outbound
    name                       = "AllowVnetOutBound"
    priority                   = 65000
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  },
  {
    name                       = "AllowAzureLoadBalancerOutBound"
    priority                   = 65001
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "AzureLoadBalancer"
  },
  {
    name                       = "DenyAllOutbound"
    priority                   = 65500
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "Internet"




  }



  
  
  
  
  
  
   ]
  







}
   