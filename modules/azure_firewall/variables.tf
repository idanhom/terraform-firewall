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
