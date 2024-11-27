
resource "azurerm_network_interface" "my_nics" {
  for_each            = var.vnets
  name                = each.value.nic_name
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}



resource "azurerm_linux_virtual_machine" "my_vms" {
  for_each = var.vnets
  name                  = "vm-${each.key}"
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = "Standard_F2"
  admin_username        = "adminuser"
  admin_password        = "Redeploy2024!!"
  network_interface_ids = [azurerm_network_interface.my_nics[each.key].id]

  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}