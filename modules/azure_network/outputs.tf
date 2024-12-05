output "debug_vnets" {
  value = var.vnets
}

output "vnet_id" {
  description = "Map of vnet names to their ID"
  value       = { for key, vnet in azurerm_virtual_network.my_vnet : key => vnet.id }
}

output "subnet_id" {
  description = "map of subnet names to their id"
  value       = { for key, subnet in azurerm_subnet.my_subnet : key => subnet.id } //learn this better
}