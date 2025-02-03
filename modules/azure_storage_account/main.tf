//break these out in their own module. for having SP upload script (docker.sh) to blob storage.
//possibly, only storage_blob_data_contributor is needed...

data "azurerm_client_config" "current" {}

resource "azurerm_role_assignment" "storage_account_contributor" {
  principal_id   = data.azurerm_client_config.current.object_id
  role_definition_name = "Storage Account Contributor"
  scope          = azurerm_storage_account.blob_storage_account.id
}

resource "azurerm_role_assignment" "storage_blob_data_contributor" {
  principal_id   = data.azurerm_client_config.current.object_id
  role_definition_name = "Storage Blob Data Contributor"
  scope          = azurerm_storage_account.blob_storage_account.id
}




locals {
  scripts_sas_url = format(
    "https://%s.blob.core.windows.net/%s/%s?%s",
    azurerm_storage_account.blob_storage_account.name,
    azurerm_storage_container.script_container.name,
    azurerm_storage_blob.script_blob.name,
    data.azurerm_storage_account_sas.scripts_sas.sas
  )
}


# module.storage_account.azurerm_storage_blob.script_blob: Refreshing state... [id=https://examplestoraccount5421.blob.core.windows.net/scripts/script.sh]
# Terraform used the selected providers to generate the following execution
# plan. Resource actions are indicated with the following symbols:
#   ~ update in-place
# Terraform planned the following actions, but then encountered a problem:
#   # module.storage_account.azurerm_storage_account_network_rules.storage_rules will be updated in-place
#   ~ resource "azurerm_storage_account_network_rules" "storage_rules" {
#         id                         = "/subscriptions/***/resourceGroups/rg_project1/providers/Microsoft.Storage/storageAccounts/examplestoraccount5421"
#       ~ ip_rules                   = [
#           - "20.246.79.245",
#           + "172.183.77.19",
#         ]
#         # (4 unchanged attributes hidden)
#     }
# Plan: 0 to add, 1 to change, 0 to destroy.
# ╷
# │ Error: retrieving properties for Blob "script.sh" (Account "Account \"examplestoraccount5421\" (IsEdgeZone false / ZoneName \"\" / Subdomain Type \"blob\" / DomainSuffix \"core.windows.net\")" / Container Name "scripts"): executing request: unexpected status 403 (403 This request is not authorized to perform this operation.) with EOF
# │ 
# │   with module.storage_account.azurerm_storage_blob.script_blob,
# │   on modules/azure_storage_account/main.tf line 61, in resource "azurerm_storage_blob" "script_blob":
# │   61: resource "azurerm_storage_blob" "script_blob" {
# │ 
# ╵
# ::error::Terraform exited with code 1.



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


resource "azurerm_storage_account_network_rules" "storage_rules" {
  storage_account_id = azurerm_storage_account.blob_storage_account.id
  default_action = "Deny" 
  virtual_network_subnet_ids = values(var.subnet_ids)
  ip_rules = [var.runner_public_ip] //allow runner ip for github actions deployment through service principal
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
    table = true #can be disabled?
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