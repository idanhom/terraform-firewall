
variable "resource_group_name" {
  description = "Name of the resource group to create"
  type        = string
}

variable "location" {
  description = "Location of the resources"
  type        = string
}

variable "subnet_ids" {
  description = "Map of subnet names to their IDs from the networking module"
  type        = map(string)
}