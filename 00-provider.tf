terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.9.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "3e00befb-2b03-4b60-b8a0-faf06ad28b5e"
}
