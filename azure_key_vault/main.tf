data "azurerm_client_config" "current" {}


resource "azurerm_key_vault" "key_vault" {
  name                = "admin-password-vm1-2"
  resource_group_name = var.resource_group_name
  location            = var.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name = "standard"
    enable_rbac_authorization       = true
    enabled_for_deployment          = true
    enabled_for_disk_encryption     = false
    enabled_for_template_deployment = false
    public_network_access_enabled   = true
    purge_protection_enabled        = false
    soft_delete_retention_days      = 90
    network_acls {
        bypass                     = "AzureServices"
        default_action             = "Allow"
        ip_rules                   = []
        virtual_network_subnet_ids = []
    }
}


resource "azurerm_key_vault_secret" "admin_username" {
  name         = "admin-username"
  value        = var.admin_username
  key_vault_id = azurerm_key_vault.key_vault.id
}

resource "azurerm_key_vault_secret" "admin_password" {
  name         = "admin-password"
  value        = var.admin_password
  key_vault_id = azurerm_key_vault.key_vault.id
}