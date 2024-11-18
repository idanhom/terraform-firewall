output "firewall_id" {
    description = "ID of firewalll"
    value = azurerm_firewall.firewall.id
}

output "firewall_ip" {
  description = "Publid IP of firewall"
  value = azurerm_public_ip.firewall_ip.ip_address
}

