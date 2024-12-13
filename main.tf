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
  subscription_id = "3e00befb-2b03-4b60-b8a0-faf06ad28b5e"
}

resource "azurerm_resource_group" "rg_project" {
  name     = var.resource_group_name
  location = var.location
}

# needed for networking module below to create its vnet inside the rg. (implicit depends-on)
output "resource_group_name" {
  value = azurerm_resource_group.rg_project.name
}

module "networking" {
  source               = "./modules/azure_network"
  resource_group_name  = azurerm_resource_group.rg_project.name
  location             = var.location
  vnets                = var.vnets
  afw                  = var.afw
  vnet_route_table = var.vnet_route_table
  # v1 of route table, from having vWAN artchitecture: firewall_route_table = var.firewall_route_table
}


module "compute" {
  source              = "./modules/azure_compute"
  resource_group_name = var.resource_group_name
  location            = var.location
  vnets               = var.vnets
  subnet_ids          = module.networking.subnet_id
}


output "firewall_private_ip_debug" {
  value = module.networking.firewall_private_ip
}


# module "monitoring" {
#   source = "./modules/azure_monitoring"
#   resource_group_name = 
#   location = 
  

#   firewall_id = module.networking.firewall_id


# }