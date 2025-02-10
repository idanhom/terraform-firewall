variable "terraform_sp_object_id" {
  description = "Object ID of the SP to assign role"
  type        = string
}

variable "script_blob_id" {
  description = "ID of the storage blob for the script"
  type        = string
}

resource "azurerm_role_assignment" "script_blob_data_contributor" {
  principal_id         = var.terraform_sp_object_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = var.script_blob_id
}
