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

//what happens if i remove these? when applied, i get both standard and my rules, which is not what i want.
variable "nsg_rules" {
  description = "rules for nsg"
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))

  default = []
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


variable "vnet_route_table" {
  description = "mapping of routes for vnets"
  type = map(map(object({
    name           = string
    address_prefix = string
    next_hop_type  = string
  })))
}


variable "workspace_retention_in_days" {
  description = "log analytics workspace saved in days"
  type        = number
  default     = 30
}


variable "log_categories" {
  description = "collection of categories to log"
  type        = list(string)
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

variable "runner_public_ip" {
  type        = string
  description = "Public IP of the GitHub Actions runner"
} 


variable "storage_account_name" {
  description = "The name of the storage account where the script is stored."
  type        = string
}

variable "container_name" {
  description = "The name of the container in the storage account where the script is stored."
  type        = string
}

variable "blob_name" {
  description = "The name of the blob (script) to be downloaded."
  type        = string
}

# variable "log_analytics_saved_search" {
#   description = "list of object for log analytics saved searches"
#   type = map(object({
#     category     = string
#     display_name = string
#     query        = string
#   }))
# }