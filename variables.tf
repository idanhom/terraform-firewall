variable "resource_group_name" {
  description = "Name of the resource group to create"
  type        = string
}

variable "location" {
  description = "Location of the resources"
  type        = string
}

variable "vnets" {
  description = "map, collection of vnet and subnets"
  type = map(object({
    vnet_name     = string
    vnet_prefix   = list(string)
    subnet_name   = string
    subnet_prefix = list(string)

    nic_name = string
    # note, add vm-attributes here, which works from having broken out fw subnet to its own
  }))
}

//what happens if i remove these? when applied, i get both standard and my rules, which is not what i want.
variable "nsg_rules" {
  description = "rules for nsg"
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))

  default = []
}


variable "afw" {
  type = object({
    firewall_vnet_name     = string
    firewall_vnet_prefix   = list(string)
    firewall_subnet_name   = string
    firewall_subnet_prefix = list(string)
    firewall_ip_name       = string
    firewall_name          = string
  })
}

variable "firewall_route_table" {
  description = "object containing firewall route table"
  type        = object({
    name = string
    internet_traffic = object({
      destinations_type = string
      destinations = list(string)
      next_hop_type = string
      next_hop_id = string
    })
    vnet_to_vnet = object({
      destinations_type = string
      destinations = list(string)
      next_hop_type = string
      next_hop_id = string
      })    
    }) 
  }