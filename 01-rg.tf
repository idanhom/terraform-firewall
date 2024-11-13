resource "azurerm_resource_group" "rg-project" {
  name     = var.resource_group_name
  location = var.location
}