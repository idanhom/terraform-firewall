# Networking for compute-resources
output "debug_vnets" {
  value = var.vnets
}

output "vnet_ids" {
  description = "map of vnet names to their id"
  value       = { for vnet_name, vnet in azurerm_virtual_network.my_vnet : vnet_name => vnet.id }
}


output "vnet_id" {
  description = "Map of vnet names to their ID"
  value       = { for vnet_name, vnet in azurerm_virtual_network.my_vnet : vnet_name => vnet.id }
}

output "subnet_id" { //should this be "subnet_ids" instead? what does this change in the rest of the code, if at all? for consistency...
  description = "map of subnet names to their id"
  value       = { for subnet_name, subnet in azurerm_subnet.my_subnet : subnet_name => subnet.id } //learn this better
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
  value       = azurerm_firewall.firewall.ip_configuration
}

output "firewall_private_ip" {
  value = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
}