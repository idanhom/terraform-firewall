terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.9"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
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
  features {}
  subscription_id = "3e00befb-2b03-4b60-b8a0-faf06ad28b5e"
}

resource "azurerm_resource_group" "rg_project" {
  name     = var.resource_group_name
  location = var.location
}

module "networking" {
    source = "./modules/azure_network"
    vnet_name = var.vnet_name
    vnet_prefix = var.vnet_prefix
    resource_group_name = var.resource_group_name
    location = var.location
    firewall_subnet_prefix = var.firewall_subnet_prefix
}

