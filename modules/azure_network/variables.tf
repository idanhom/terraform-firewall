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
  }))
}


# Firewall vars
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
#
variable "vnet_route_table" {
  description = "mapping of routes for vnets"
  type = map(map(object({
    name           = string
    address_prefix = string
    next_hop_type  = string
  })))
}


variable "vm_private_ip" {
  description = "map of vm names to their private ip addresses"
  type        = map(string)
}

