output "vnet_id" {
    description = "The ID of the vnet"
    value = azurerm_virtual_network.my_vnet.id  
}

output "subnet_id" {
 description = "id of subnets"
 value = azurerm_subnet.my_subnet[*].id
}

output "firewall_subnet_id" {
    description = "The ID of the firewall subnet"
    value = azurerm_subnet.firewall_subnet.id
}
