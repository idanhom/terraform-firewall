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


