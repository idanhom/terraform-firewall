output "vm_private_ip" {
  description = "map of private ip for vms"
  value = { for vnet_name, vm in azurerm_linux_virtual_machine.my_vms : vnet_name => vm.private_ip_address}
  sensitive = false
}
