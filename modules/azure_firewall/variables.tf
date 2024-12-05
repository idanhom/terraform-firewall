variable "resource_group_name" {
  description = "Name of the resource group to create"
  type        = string
}

variable "location" {
  description = "Location of the resources"
  type        = string
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

