# note, for simplicity, i have disabled github actions while i work on this.
# active it here: https://github.com/idanhom/terraform-firewall/settings/actions


terraform {
  required_version = "~>1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.9"
    }
  }

  backend "azurerm" {
    resource_group_name  = "terraformstate-rg"
    storage_account_name = "statecontainer001"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  storage_use_azuread = true
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}


# data "azurerm_client_config" "current" {}




resource "azurerm_resource_group" "rg_project" {
  name     = var.resource_group_name
  location = var.location
}

# needed for networking module below to create its vnet inside the rg. (implicit depends-on)
output "resource_group_name" {
  value = azurerm_resource_group.rg_project.name
}

module "networking" {
  source              = "./modules/azure_network"
  resource_group_name = azurerm_resource_group.rg_project.name
  location            = var.location
  vnets               = var.vnets
  afw                 = var.afw
  vnet_route_table    = var.vnet_route_table
  vm_private_ip       = module.compute.vm_private_ip
  # v1 of route table, from having vWAN artchitecture: firewall_route_table = var.firewall_route_table
}

#
module "compute" {
  source              = "./modules/azure_compute"
  resource_group_name = azurerm_resource_group.rg_project.name
  location            = var.location
  vnets               = var.vnets
  #subnet_ids = module.networking.subnet_id //commented out because replaced with _ids instead.

  vnet_ids   = module.networking.vnet_ids
  subnet_ids = module.networking.subnet_ids


  admin_username = var.admin_username
  admin_password = var.admin_password

  storage_account_name = module.storage_account.storage_account_name
  container_name       = module.storage_account.container_name
  blob_name            = module.storage_account.blob_name
  custom_data_sas_url  = module.storage_account.scripts_sas_url
}


module "monitoring" {
  source = "./modules/azure_monitoring"

  resource_group_name = azurerm_resource_group.rg_project.name
  location            = var.location

  firewall_id = module.networking.firewall_id

  workspace_retention_in_days = var.workspace_retention_in_days
  log_categories              = var.log_categories

  depends_on = [module.networking]
}

module "storage_account" {
  source              = "./modules/azure_storage_account"
  resource_group_name = azurerm_resource_group.rg_project.name
  location            = var.location
  subnet_ids          = module.networking.subnet_ids
  vnet_ids            = module.networking.vnet_ids
  terraform_sp_object_id = var.terraform_sp_object_id
  runner_public_ip    = var.runner_public_ip
}

