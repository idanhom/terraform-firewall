variable "terraform_sp_object_id" {
  description = "Object ID of the SP to assign role"
  type        = string
}

variable "script_blob_id" {
  description = "ID of the storage blob for the script"
  type        = string
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}
