resource "azurerm_resource_group" "rg_project" {
  name     = var.resource_group_name
  location = var.location
}