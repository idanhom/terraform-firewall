# note, for simplicity, i have disabled github actions while i work on this.
# active it here: https://github.com/idanhom/terraform-firewall/settings/actions


terraform {
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
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  # subscription env set locally and using CI/CD to troubleshoot code easier without going through github actions 
  # subscription_id = "3e00befb-2b03-4b60-b8a0-faf06ad28b5e"
}


data "azurerm_client_config" "current" {}



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


module "compute" {
  source              = "./modules/azure_compute"
  resource_group_name = azurerm_resource_group.rg_project.name
  # previously, it was var.resource_group_name
  location   = var.location
  vnets      = var.vnets
  subnet_ids = module.networking.subnet_id

  admin_username = var.admin_username
  admin_password = var.admin_password

}



module "monitoring" {
  source = "./modules/azure_monitoring"

  resource_group_name = azurerm_resource_group.rg_project.name
  # previously, it was var.resource_group_name
  location = var.location

  firewall_id = module.networking.firewall_id

  workspace_retention_in_days = var.workspace_retention_in_days
  log_categories              = var.log_categories

  #log_analytics_saved_search = var.log_analytics_saved_search // shouldn't this change given i do query pack now instead of saved search?

  depends_on = [module.networking]
}

module "storage_account" {
  source = "./modules/azure_storage_account"
  resource_group_name = var.resource_group_name 
  location = var.location
  vnets = var.vnets
  subnet_ids = module.networking.subnet_id
}

