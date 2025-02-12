resource "azurerm_role_assignment" "script_blob_data_contributor" {
  principal_id         = var.terraform_sp_object_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = var.script_blob_id
}
