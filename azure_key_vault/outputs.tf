
output "key_vault_id" {
  value = azurerm_key_vault.key_vault.id
}

output "admin_username_secret_name" {
  value = azurerm_key_vault_secret.admin_username.name
}

output "admin_password_secret_name" {
  value = azurerm_key_vault_secret.admin_password.name
}