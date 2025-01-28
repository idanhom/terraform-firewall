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
#------------------------------------------------

# resource "azurerm_role_assignment" "storage_blob_data_contributor" {
#   principal_id        = var.terraform_sp_object_id # Directly use SP's Object ID
#   role_definition_name = "Storage Blob Data Contributor"
#   scope               = azurerm_storage_account.blob_storage_account.id
# }





# resource "null_resource" "delay" {
#   depends_on = [azurerm_role_assignment.storage_blob_data_contributor]
#   provisioner "local-exec" {
#     command = "sleep 15" # Wait for 15 seconds
#   }
# }

#------------------------------------------------
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
  large_file_share_enabled        = true //false?
  shared_access_key_enabled       = true

  # blob_properties {
  #   container_delete_retention_policy {
  #     days = 7
  #   }

  #   delete_retention_policy {
  #     days                     = 7
  #     permanent_delete_enabled = false
  #   }
  # }

/*   network_rules {
    default_action = "Deny"
    bypass = ["AzureServices"]

    virtual_network_subnet_ids = [
      for k, subnet_id in var.subnet_ids : subnet_id
    ]

    private_link_access {
      endpoint_resource_id = [
        for k, subnet_id in var.subnet_ids : subnet_id
      ]
    }
    }
   */

  
  
  # network_rules {
  #   default_action = "Deny" # Preferred 'Deny' but SP doesn't have right RBAC to deploy script to storage
  #   bypass = ["AzureServices"]
  #   private_link_access {
  #     endpoint_resource_id = [
  #       for k, subnet_id in var.subnet_ids : subnet_id
  #     ]
  #   }
  #   #ip_rules = [var.runner_public_ip] //remnant from trying to allow SP to deploy script to script container. however for this to work i need a self-hosted runner in a vnet...
  # }

  # share_properties {
  #   retention_policy {
  #     days = 7
  #   }
  # }
}

resource "azurerm_storage_account_network_rules" "storage_rules" {
  storage_account_id = azurerm_storage_account.blob_storage_account.id

  default_action = "Deny" # when i allow, it works. but this is bad practice. 
  bypass         = ["AzureServices"]

  virtual_network_subnet_ids = values(var.subnet_ids)
}

resource "azurerm_storage_account_network_rules" "private_link_access" {
  for_each = var.subnet_ids 

  storage_account_id = azurerm_storage_account.blob_storage_account.id

  default_action = "Deny"
  bypass = ["AzureServices"]

}
###################
# version 2...? fix
resource "azurerm_storage_account_network_rules" "this" {
  storage_account_id = azurerm_storage_account.blob_storage_account.id
  default_action     = "Deny"
  bypass            = ["AzureServices"]

  virtual_network_subnet_ids = values(var.subnet_ids)

  dynamic "private_link_access" {
    for_each = var.subnet_ids
    content {
      endpoint_resource_id = ...
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
  source                 = "${path.module}/custom_data/docker.sh"
  #depends_on = [azurerm_storage_container.script_container]
}



data "azurerm_storage_account_sas" "scripts_sas" {
  connection_string = azurerm_storage_account.blob_storage_account.primary_connection_string
  https_only        = true
  #signed_version    = "2022-11-02"

  resource_types {
    service   = true
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = true
    file  = false
  }

  start  = timestamp()
  expiry = timeadd(timestamp(), "3h")

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
  #depends_on = [azurerm_storage_account.blob_storage_account] //can be removed because of implicit dep. from private_connection_...
}



resource "azurerm_private_dns_a_record" "storage_blob_a_record" {
  # We also do for_each on var.subnet_ids to match the multiple endpoints above.
  for_each = var.subnet_ids

  name                = azurerm_storage_account.blob_storage_account.name
  zone_name           = azurerm_private_dns_zone.blob_dns_zone.name
  resource_group_name = var.resource_group_name
  ttl                 = 300

  records = [
    # Link each A-record to the correct private endpoint’s IP address
    azurerm_private_endpoint.blob_private_endpoint[each.key].private_service_connection[0].private_ip_address
  ]
}


