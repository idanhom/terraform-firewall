variable "location" {
  description = "Location of the resources"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group to create"
  type        = string
}

variable "nic_name" {
  description = "name of nic"
  type = list(string)
}

