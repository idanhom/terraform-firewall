variable "resource_group_name" {
  description = "Name of the resource group to create"
  type        = string
}

variable "location" {
  description = "Location of the resources"
  type        = string
}

variable "workspace_retention_in_days" {
  description = "log analytics workspace saved in days"
  type = number
  default = 30
}

variable "target_resource_id" {
  description = "the ID of the resource to monitor"
  type = string  
}

variable "log_categories" {
  description = "collection of categories to log"
  type = list(string)
}

variable "log_analytics_saved_search" {
  description = "list of object for log analytics saved searches"
  type = list(object({
    name = string
    category = string
    display_name = string
    query = string
  }))
}