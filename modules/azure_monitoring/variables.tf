variable "resource_group_name" {
  description = "Name of the resource group to create"
  type        = string
}

variable "location" {
  description = "Location of the resources"
  type        = string
}

# variable "workspace_retention_in_days" {
#   description = "log analytics workspace saved in days"
#   type = number
#   default = 30
# }

variable "firewall_id" {
  description = "ID of azure firewall"
  type        = string
}