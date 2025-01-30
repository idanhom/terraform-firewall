output "firewall_ip" {
  description = "public ip of afw"
  value       = module.networking.firewall_ip
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


output "scripts_sas_token" {
  value     = module.storage_account.scripts_sas_token
  sensitive = true
}

output "scripts_sas_url_main" {
  value       = module.storage_account.scripts_sas_url
  description = "The SAS URL for the script blob, used for deployment"
  sensitive   = true
}
