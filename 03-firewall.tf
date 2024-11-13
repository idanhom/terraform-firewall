resource "azurerm_firewall" "firewall" {
  name                = var.firewall_name
  location            = azurerm_resource_group.rg-project.location
  resource_group_name = azurerm_resource_group.rg-project.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.firewall-subnet.id
    public_ip_address_id = azurerm_public_ip.firewall-ip.id
  }
}