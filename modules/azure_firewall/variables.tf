variable "resource_group_name" {
  description = "Name of the resource group to create"
  type        = string
}

variable "location" {
  description = "Location of the resources"
  type        = string
}

variable "firewall_ip_name" {
  description = "Name of the firewall public IP"
  type        = string
}

variable "firewall_name" {
  description = "Name of the firewall"
  type        = string
}

variable "firewall_subnet_id" {
  description = "The ID of the firewall subnet"
  type        = string
}

variable "firewall_vnet_name" {
  description = "name of firewall vnet name"
  type = string
}


variable "firewall_vnet_prefix" {
  description = "cidr of firewall vnet prefix"
  type = list(string)
}

variable "firewall_subnet_name" {
  description = "name of firewall subnet name"
  type = string
}

variable "firewall_subnet_prefix" {
  description = "cidr of firewall subnet prefix"
  type = list(string)
  
}

variable "firewall_ip_name" {
  description = "firewall ip name"
  type = string
}

variable "firewall_ip_name" {
  description = "firewall name"
  type = string  
}

