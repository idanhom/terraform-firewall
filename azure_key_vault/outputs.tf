
output "key_vault_id" {
  value = azurerm_key_vault.key_vault.id
}

output "admin_username_secret_value" {
  value = azurerm_key_vault_secret.admin_username.value
  sensitive = true
}

output "admin_password_secret_value" {
  value = azurerm_key_vault_secret.admin_password.value
  sensitive = true
}
