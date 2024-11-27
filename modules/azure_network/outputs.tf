output "vnet_id" {
  description = "Map of vnet names to their ID"
  value       = {for name, vnet in azurerm_virtual_network.my_vnet : name => vnet.id}
}

output "subnet_id" {
  description = "map of subnet names to their id"
  value       = { for name, subnet in azurerm_subnet.my_subnet : name => subnet.id } //learn this better
}
