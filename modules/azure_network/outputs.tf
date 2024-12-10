# Networking for compute-resources
output "debug_vnets" {
  value = var.vnets
}

# how to make sure both subnet names are outputted?
output "subnet_outputs" {
  value = azurerm_subnet.my_subnet.id
}

output "vnet_id" {
  description = "Map of vnet names to their ID"
  value       = { for key, vnet in azurerm_virtual_network.my_vnet : key => vnet.id }
}

output "subnet_id" {
  description = "map of subnet names to their id"
  value       = { for key, subnet in azurerm_subnet.my_subnet : key => subnet.id } //learn this better
}

# Firewall resources
output "firewall_subnet_id" {
  description = "The ID of the firewall subnet"
  value       = azurerm_subnet.firewall_subnet.id
}


output "firewall_id" {
  description = "ID of firewalll"
  value       = azurerm_firewall.firewall.id
}

output "firewall_ip" {
  description = "Public IP of firewall"
  value       = azurerm_public_ip.firewall_ip.ip_address
}