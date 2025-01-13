output "storage_account_name" {
  value = azurerm_storage_account.blob_storage_account.name
}

output "container_name" {
  value = azurerm_storage_container.script_container.name
}

output "blob_name" {
  value = azurerm_storage_blob.script_blob.name
}

output "read_only_sas_token" {
  value = azurerm_storage_account_sas.blob_read_sas.sas
}

output "read_only_blob_url_with_sas" {
  value = "${azurerm_storage_blob.script_blob.url}${azurerm_storage_account_sas.blob_read_sas.sas}"
}