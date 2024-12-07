variable "resource_group_name" {
  description = "Name of the resource group to create"
  type        = string
}

variable "location" {
  description = "Location of the resources"
  type        = string
}

/* variable "firewall_subnet_prefix" {
  description = "CIDR for the firewall subnet prefix"
  type        = list(string)
} */

//commented out because firewall subnet name needs only one naming
# variable "firewall_subnet_name" {
#   description = "name of firewall subnet (do not change)"
#   type        = string
/* variable "firewall_name" {
  description = "name of firewall"
  type        = string
}

variable "firewall_ip_name" {
  description = "name of ip for firewall"
  type        = string
} */

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


# variable "firewall_subnet_id" {
#   description = "The ID of the firewall subnet"
#   type        = string
# }

/* variable "firewall_vnet_name" {
  description = "name of firewall vnet name"
  type        = string
}

variable "firewall_vnet_prefix" {
  description = "cidr of firewall vnet prefix"
  type        = list(string)
}

variable "firewall_subnet_name" {
  description = "name of firewall subnet name"
  type        = string
} */

# variable "nic_name" {
#   description = "map of subnet names to their IDs"
#   type        = map(string)
# }