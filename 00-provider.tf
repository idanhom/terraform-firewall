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
    resource_group_name   = var.resource_group_name
    storage_account_name  = var.storage_account_name
    container_name        = var.container_name
    key = "terraform.tfstate"
}
}



provider "azurerm" {
  features {}
  subscription_id = "3e00befb-2b03-4b60-b8a0-faf06ad28b5e"
}


