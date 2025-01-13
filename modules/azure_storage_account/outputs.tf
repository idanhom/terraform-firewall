output "storage_account_name" {
  value = azurerm_storage_account.blob_storage_account.name
}

output "container_name" {
  value = azurerm_storage_container.script_container.name
}

output "blob_name" {
  value = azurerm_storage_blob.script_blob.name
}