variable "resource_group_name" {
  description = "Name of the resource group to create"
  type        = string
}

variable "location" {
  description = "Location of the resources"
  type        = string
}

variable "nic_name" {
  description = "liset of nic names"
  type        = map(string)
}

variable "subnet_ids" {
  description = "map of subnet names to their IDs"
  type        = map(string)
}