resource "azurerm_public_ip" "firewall_ip" {
  name                = var.firewall_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard" 
  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_firewall" "firewall" {
  name                = var.firewall_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.firewall_subnet.id //unclear. ChatGPT says this: "var.firewall_subnet_id and comment: ""The firewall_subnet_id is an input because it depends on the networking module.
    public_ip_address_id = azurerm_public_ip.firewall_ip.id
  }
}