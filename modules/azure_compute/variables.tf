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
    # note, add vm-attributes here, which works from having broken out fw subnet to its own
  }))
}

# variable "nic_name" {
#   description = "liset of nic names"
#   type        = map(string)
# }

# variable "subnet_ids" {
#   description = "map of subnet names to their IDs"
#   type        = map(string)
# }

