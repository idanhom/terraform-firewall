# Note, have currently opened up the networking too wide. See arg like public_network_access_enabled and block network_rules (default_action)
# see this gpt, and note that it's o1....
#https://chatgpt.com/c/67866ed2-4940-800b-9f52-e8e347d55182
# https://chatgpt.com/g/g-pDLabuKvD-terraform-guide/c/67866ea3-e628-800b-947a-4ce87035ddd1


# https://learn.microsoft.com/en-us/azure/storage/common/storage-private-endpoints


locals {
  scripts_sas_url = format(
    "https://%s.blob.core.windows.net/%s/%s?%s",
    azurerm_storage_account.blob_storage_account.name,
    azurerm_storage_container.script_container.name,
    azurerm_storage_blob.script_blob.name,
    data.azurerm_storage_account_sas.scripts_sas.sas
  )
}

resource "azurerm_storage_account" "blob_storage_account" {
  name                            = "examplestoraccount5421"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  access_tier                     = "Cool"
  public_network_access_enabled   = true //Note: this should be "false" to disable public access?
  default_to_oauth_authentication = true

  allow_nested_items_to_be_public = false
  https_traffic_only_enabled      = true
  large_file_share_enabled        = true
  shared_access_key_enabled       = true

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
    default_action = "Allow" //note, this should be "Deny" to block public access?
    ip_rules = [var.runner_public_ip] # does this serve a purpose?
    bypass = ["AzureServices"]
    /*     private_link_access {
      endpoint_resource_id = azurerm_private_endpoint.example.id
    } */
  }

  share_properties {
    retention_policy {
      days = 7
    }
  }
}


resource "azurerm_storage_container" "script_container" {
  name                  = "scripts"
  storage_account_id    = azurerm_storage_account.blob_storage_account.id
  container_access_type = "private"
}


resource "azurerm_storage_blob" "script_blob" {
  name                   = "script.sh"
  storage_account_name   = azurerm_storage_account.blob_storage_account.name
  storage_container_name = azurerm_storage_container.script_container.name
  type                   = "Block"
  source                 = "${path.module}/custom_data/docker.sh" # Path to your local file

  depends_on = [azurerm_storage_container.script_container]
}



resource "azurerm_private_dns_zone" "blob_dns_zone" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_zone_link" {
  for_each = var.vnet_ids

  name                  = "${each.key}-blob-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.blob_dns_zone.name
  virtual_network_id    = each.value
}

resource "azurerm_private_endpoint" "blob_private_endpoint" {
  for_each = var.subnet_ids

  name                = "${each.key}-blob-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = each.value

  private_service_connection {
    name                           = "${each.key}-blob-endpoint"
    private_connection_resource_id = azurerm_storage_account.blob_storage_account.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
  depends_on = [azurerm_storage_account.blob_storage_account] //can be removed because of implicit dep. from private_connection_...
}



data "azurerm_storage_account_sas" "scripts_sas" {
  connection_string = azurerm_storage_account.blob_storage_account.primary_connection_string
  https_only        = true
  signed_version    = "2022-11-02"

  # Define the resource types
  resource_types {
    service   = true
    container = true
    object    = true
  }

  # Define the storage account services
  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  # Use dynamic time for start and expiry
  start  = timestamp()                       # Current time in ISO-8601 format
  expiry = timeadd(timestamp(), "24h")       # Add 24 hours to the current time

  # Define the permissions
  permissions {
    read    = true
    create  = true
    write   = true
    list    = false
    delete  = false
    add     = false
    update  = false
    process = false
    tag     = false
    filter  = false
  }
  depends_on = [azurerm_storage_blob.script_blob]
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