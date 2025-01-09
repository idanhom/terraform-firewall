
variable "resource_group_name" {
  description = "Name of the resource group to create"
  type        = string
}

variable "location" {
  description = "Location of the resources"
  type        = string
}

variable "key_vault" {
  description = "name of key vault"
  type        = string
}

variable "admin_username" {
  description = "Admin username for the Linux VM"
  type        = string
}

variable "admin_password" {
  description = "Admin password for the Linux VM"
  type        = string
  sensitive   = true
}