output "vnet_id" {
    description = "The ID of the vnet"
    value = azurerm_virtual_network.my_vnet.id  
}

output "firewall_subnet_id" {
    description = "The ID of the firewall subnet"
    value = azurerm_subnet.firewall_subnet.id
}
