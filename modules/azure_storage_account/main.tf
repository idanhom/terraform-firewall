data "azurerm_client_config" "current" {}

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
  public_network_access_enabled   = true // enabled because i need SP to deploy script. otherwise would need self-hosted SP runner and enable network connection from it to storage account.
  default_to_oauth_authentication = true
  allow_nested_items_to_be_public = false
  https_traffic_only_enabled      = true
  large_file_share_enabled        = true
  shared_access_key_enabled       = true
}
#

resource "azurerm_storage_account_network_rules" "storage_rules" {
  storage_account_id         = azurerm_storage_account.blob_storage_account.id
  default_action             = "Deny" //since using github actions runners, need "Allow" at initial deployment for SP to deploy script. then "Deny". robust solution: self hosted runner with static ip and allow vnet in storage account rule.
  virtual_network_subnet_ids = values(var.subnet_ids)
  ip_rules                   = ["20.123.40.106"] //static ip of self-hosted runner. need to also allow subnet of self-hosted runner    #[var.runner_public_ip] //allow runner ip for github actions deployment through service principal
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
  source                 = "${path.module}/custom_data/docker.sh"
  depends_on             = [azurerm_storage_container.script_container]
}

data "azurerm_storage_account_sas" "scripts_sas" {
  connection_string = azurerm_storage_account.blob_storage_account.primary_connection_string
  https_only        = true

  resource_types {
    service   = true
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false 
    file  = false
  }

  start  = timestamp()
  expiry = timeadd(timestamp(), "3h")

  permissions {
    read    = true
    write   = true # can be disabled?
    create  = true # can be disabled?
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

resource "azurerm_private_dns_zone" "blob_dns_zone" {
  name                = "privatelink.blob.core.windows.net" //FQDN for private link for securing access to blob
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
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.blob_storage_account.id
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name = "default"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.blob_dns_zone.id
    ]
  }
}

output "script_blob_id" {
  value = azurerm_storage_blob.script_blob.id
}