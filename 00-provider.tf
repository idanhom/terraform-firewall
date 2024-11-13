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
    resource_group_name   = "terraformstate-rg"
    storage_account_name  = "statecontainer001"
    container_name        = "tfstate"
    key = "terraform.tfstate"
}
}



provider "azurerm" {
  features {}
  subscription_id = "3e00befb-2b03-4b60-b8a0-faf06ad28b5e"
}


