output "storage_account_name" {
  value = azurerm_storage_account.blob_storage_account.name
}

output "container_name" {
  value = azurerm_storage_container.script_container.name
}

output "blob_name" {
  value = azurerm_storage_blob.script_blob.name
}

output "sas_token" {
  value = data.azurerm_storage_account_sas.blob_read_sas.sas
}

output "blob_url_with_sas" {
  value = "${azurerm_storage_blob.script_blob.url}${data.azurerm_storage_account_sas.blob_read_sas.sas}"
}

output "blob_url" {
  value = azurerm_storage_blob.script_blob.url
}
