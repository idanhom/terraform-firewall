terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.9"
    }
    # random = {
    #   source  = "hashicorp/random"
    #   version = "3.6.3"
    # }
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
  source                 = "./modules/azure_network"
  resource_group_name    = var.resource_group_name
  location               = var.location
  vnet_name              = var.vnet_name
  vnet_prefix            = var.vnet_prefix
  #subnet_name            = var.subnet_name
  #subnet_address_prefix  = var.subnet_address_prefix
  firewall_subnet_prefix = var.firewall_subnet_prefix
  firewall_name          = var.firewall_name
  firewall_ip_name       = var.firewall_ip_name
  subnets = var.subnets
  //should nsg be specified here? it's already created and associated with subnet...
}

module "compute" {
  source              = "./modules/azure_compute"
  resource_group_name = var.resource_group_name
  location            = var.location
  nic_name            = var.nic_name
  subnet_ids          = module.networking.subnet_id


}


# module "firewall" {

# }


