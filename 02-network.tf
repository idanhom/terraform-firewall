

resource "azurerm_public_ip" "firewall_ip" {
  name                = var.firewall_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard" //public ip 
  lifecycle {
    create_before_destroy = true
  }
}
