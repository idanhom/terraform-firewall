output "storage_account_name" {
  value = azurerm_storage_account.blob_storage_account.name
}

output "container_name" {
  value = azurerm_storage_container.script_container.name
}

output "blob_name" {
  value = azurerm_storage_blob.script_blob.name
}



output "scripts_sas_url" {
  value = local.scripts_sas_url
}



# Note: difference between below? _main is in outputs main to see if script url works
output "scripts_sas_token" {
  value = data.azurerm_storage_account_sas.scripts_sas.sas
}

output "scripts_sas_url_main" {
  value       = local.scripts_sas_url
  description = "The SAS URL for the script blob, used for deployment"
}


/* output "sas_token" {
  value = data.azurerm_storage_account_sas.blob_read_sas.sas
}

output "blob_url_with_sas" {
  value = "${azurerm_storage_blob.script_blob.url}${data.azurerm_storage_account_sas.blob_read_sas.sas}"
}

output "blob_url" {
  value = azurerm_storage_blob.script_blob.url
}
 */