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
  #subscription_id = "3e00befb-2b03-4b60-b8a0-faf06ad28b5e"

  subscription_id = env.ARM_SUBSCRIPTION_ID
  tenant_id       = env.ARM_TENANT_ID
  client_id       = env.ARM_CLIENT_ID

}



# # For GitHub's CI/CD
# resource "azurerm_user_assigned_identity" "github_actions_identity" {
#   name                = "github-actions-identity"
#   resource_group_name = "terraformstate-rg"
#   location            = var.location
# }


# here we also neeed a federated...
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_oidc
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential



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
  vm_private_ip = module.compute.vm_private_ip
  # v1 of route table, from having vWAN artchitecture: firewall_route_table = var.firewall_route_table
}


module "compute" {
  source              = "./modules/azure_compute"
  resource_group_name = azurerm_resource_group.rg_project.name
# previously, it was var.resource_group_name
  location            = var.location
  vnets               = var.vnets
  subnet_ids          = module.networking.subnet_id
}



module "monitoring" {
  source = "./modules/azure_monitoring"

  resource_group_name = azurerm_resource_group.rg_project.name
# previously, it was var.resource_group_name
  location            = var.location

  firewall_id = module.networking.firewall_id

  workspace_retention_in_days = var.workspace_retention_in_days
  log_categories              = var.log_categories

  log_analytics_saved_search = var.log_analytics_saved_search

  depends_on = [ module.networking ]

}



