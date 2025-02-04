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

variable "vnet_ids" {
  description = "Map of VNet names to their IDs"
  type        = map(string)
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

variable "storage_account_name" {
  description = "The name of the storage account where the script is stored."
  type        = string
}

variable "container_name" {
  description = "The name of the container in the storage account where the script is stored."
  type        = string
}


variable "blob_name" {
  description = "The name of the blob in the container where the script is stored."
  type        = string
}


variable "custom_data_sas_url" {
  description = "The SAS URL for the custom script blob"
  type        = string
}

variable "storage_account_module" {
  description = "Reference to the storage account module to enforce dependencies"
  type        = any
}


/* variable "storage_blob_id" {
  description = "The ID of the script blob in the storage account"
  type        = string
} */


/* variable "blob_name" {
  description = "The name of the blob (script) to be downloaded."
  type        = string
}

variable "blob_url_with_sas" {
  description = "The full URL of the blob including the SAS token"
  type        = string
} */