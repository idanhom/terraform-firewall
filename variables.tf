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
  }))
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

variable "terraform_sp_object_id" {
  description = "The Object ID of the Service Principal used by Terraform"
  type        = string
}

variable "runner_public_ip" {
  type        = string
  description = "Public IP of the GitHub Actions runner"
}

# variable "storage_blob_id" {
#   description = "The ID of the script blob in the storage account"
#   type        = string
# }
