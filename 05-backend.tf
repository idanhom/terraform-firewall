resource "azurerm_storage_account" "storage_account" {
  name                     = "storage_account-${random_string.random_suffix}"
  location            = azurerm_resource_group.rg-project.location
  resource_group_name = azurerm_resource_group.rg-project.name
  account_tier             = "Standard"
  account_replication_type = "GRS"
  account_kind = "StorageV2"
  blob_properties {
    restore_policy {
      days = 30
    }
    delete_retention_policy {
      days = 30
    }
    versioning_enabled = true
    change_feed_enabled = true
    change_feed_retention_in_days = 90
  }


}

resource "azurerm_storage_container" "state_container" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.storage_account.id
  container_access_type = "private"
}