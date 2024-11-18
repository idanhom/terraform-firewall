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
  type        = string
}

variable "subnet_address_prefix" {
  description = "CIDR block for subnet"
  type        = list(string)
}

variable "firewall_subnet_prefix" {
  description = "CIDR for the firewall subnet prefix"
  type        = list(string)
}

