# here is want to make sure the private endpoints are using a for_each code loop.
# also, what other changes do i need to do to make this happen?
# here is the chatgpt conversation i have to read up on:
# https://chatgpt.com/g/g-pDLabuKvD-terraform-guide/c/677fbdab-9568-800b-b998-865efb115ab8

# also, when deploying this text, is it to this resource group or not?
# perhaps i need to import these resources to this state file? (since they're created outside of it)

# also, i need to expose... the url of the blob so the vm can take it and deploy?
# start deploy  
resource "azurerm_storage_account" "example" {
  name                     = "examplestoraccount5421"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "RAGRS"
  account_kind             = "StorageV2"
  access_tier              = "Cool"

  allow_nested_items_to_be_public   = false
  https_traffic_only_enabled        = true
  large_file_share_enabled          = true
  min_tls_version                   = "TLS1_2"
  shared_access_key_enabled         = true

  blob_properties {
    container_delete_retention_policy {
      days = 7
    }

    delete_retention_policy {
      days                     = 7
      permanent_delete_enabled = false
    }
  }

  network_rules {
    default_action = "Deny"
    bypass = [
      "AzureServices",
    ]
  }

  share_properties {
    retention_policy {
      days = 7
    }
  }
}


resource "azurerm_storage_container" "example" {
  name                    = "script"
  storage_account_id   = azurerm_storage_account.example.id
  container_access_type   = "private"
}


resource "azurerm_storage_blob" "script" {
  name                   = "script.sh"
  storage_account_name   = azurerm_storage_account.example.name
  storage_container_name = azurerm_storage_container.example.name
  type                   = "Block" 
  source                 = "${path.module}/modules/azure_storage_account/custom_data/script.sh" # Path to your local file
}


resource "azurerm_private_endpoint" "example" {
  for_each = var.subnet_ids

  name = "${each.key}_access"
  location = var.location
  resource_group_name = var.resource_group_name
  subnet_id = each.value

  private_service_connection {
    name                           = "${each.key}_connection"
    private_connection_resource_id = azurerm_storage_account.example.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
}

/* 

resource "azurerm_private_endpoint" "example1" {
  name                = "vnet1_access"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = "/subscriptions/3e00befb-2b03-4b60-b8a0-faf06ad28b5e/resourceGroups/rg_project1/providers/Microsoft.Network/virtualNetworks/vnet1/subnets/subnet1"

  private_service_connection {
    name                              = "vnet1_access_connection"
    is_manual_connection = false
    private_connection_resource_id    = azurerm_storage_account.example.id
    subresource_names                 = ["blob"]
  }
}


resource "azurerm_private_endpoint" "example2" {
  name                = "vnet2_access"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = "/subscriptions/3e00befb-2b03-4b60-b8a0-faf06ad28b5e/resourceGroups/rg_project1/providers/Microsoft.Network/virtualNetworks/vnet2/subnets/subnet2"

  private_service_connection {
    name                              = "vnet2_access_connection"
    is_manual_connection = false
    private_connection_resource_id    = azurerm_storage_account.example.id
    subresource_names                 = ["blob"]
  }
}

 */