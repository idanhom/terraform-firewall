resource "azurerm_network_interface" "my_nics" {
  for_each            = var.vnets
  name                = each.value.nic_name
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_ids[each.key]
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "my_vms" {
  for_each              = var.vnets
  name                  = "vm-${each.key}"
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = "Standard_F2"
  network_interface_ids = [azurerm_network_interface.my_nics[each.key].id]


  custom_data = base64encode(<<EOT
#!/bin/bash
# Download the script from blob storage with SAS token
  curl -f -o /tmp/script.sh "${var.custom_data_sas_url}"
  chmod +x /tmp/script.sh
  /tmp/script.sh
  EOT
  )

  admin_username = var.admin_username //theadmintothevm
  admin_password = var.admin_password //Redeploy2025!!
  // touch disable_password_auth for ssh key-implementation? how does it affect with key vault?
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

  lifecycle {
    prevent_destroy = false
  }
}