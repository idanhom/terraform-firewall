
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

variable "vnet_ids" {
  description = "Map of vnet names to their IDs from the networking module"
  type        = map(string)
}

variable "terraform_sp_object_id" {
  description = "The Client ID of the Terraform Service Principal"
}



/* variable "runner_public_ip" {
  type        = string
  description = "Public IP of the GitHub Actions runner"
}

 */