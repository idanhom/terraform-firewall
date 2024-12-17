output "vm_private_ip" {
  description = "map of private ip for vms"
  value = { for vnet_name, vm in azurerm_linux_virtual_machine.my_vms : vnet_name => vm.private_ip_address}
  sensitive = false
}

output "vm_public_ip" {
  description = "map of public ip to vms"
  value = { for vnet_name, pip in azurerm_public_ip.my_pip : vnet_name => pip.ip_address}
}