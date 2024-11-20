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

//commented out because firewall subnet name needs only one naming
# variable "firewall_subnet_name" {
#   description = "name of firewall subnet (do not change)"
#   type        = string
# }

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


variable "nic_name" {
  description = "name of nic"
  type = list(string)
}