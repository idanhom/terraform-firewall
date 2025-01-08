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

variable "subnet_ids" {
  description = "map of subnet names to their IDs"
  type        = map(string)
}

variable "key_vault_id" {
  description = "ID of the Key Vault to retrieve secrets from"
  type        = string
}

variable "admin_username_secret_name" {
  description = "Name of the admin username secret in the Key Vault"
  type        = string
}

variable "admin_password_secret_name" {
  description = "Name of the admin password secret in the Key Vault"
  type        = string
}