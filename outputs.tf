output "firewall_private_ip_debug" {
  value = module.networking.firewall_ip
}

output "vnet_ids" {
  description = "Map of vnet names to their IDs"
  value       = module.networking.vnet_ids
}

output "subnet_ids" {
  description = "map of subnet names to their id"
  value       = module.networking.subnet_ids
}

output "vm_private_ip" {
  description = "map of vms to private ip"
  value       = module.compute.vm_private_ip

}

output "vm_public_ip" {
  description = "map of vm to public ip"
  value       = module.compute.vm_public_ip
}

output "blob_url" {
  description = "url of SAS token to container"
  value = module.storage_account.blob_url
}