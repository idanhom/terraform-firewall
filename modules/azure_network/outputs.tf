output "vnet_id" {
  description = "The ID of the vnet"
  value       = azurerm_virtual_network.my_vnet.id
}

output "subnet_id" {
  description = "map of subnet names to their id"
  value       = { for name, subnet in azurerm_subnet.my_subnet : name => subnet.id } //learn this better
}

output "firewall_subnet_id" {
  description = "The ID of the firewall subnet"
  value       = azurerm_subnet.firewall_subnet.id
}
