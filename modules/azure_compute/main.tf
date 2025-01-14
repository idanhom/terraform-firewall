

//to be disabled because using the firewall ip?
resource "azurerm_public_ip" "my_pip" {
  for_each            = var.vnets
  name                = "pip-${each.key}"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "my_nics" {
  for_each            = var.vnets
  name                = each.value.nic_name
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_ids[each.key]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.my_pip[each.key].id
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
# Download the script from blob storage 
curl -o /tmp/script.sh "https://${azurerm_storage_account.blob_storage_account.name}.blob.core.windows.net/${azurerm_storage_container.script_container.name}/${azurerm_storage_blob.script_blob.name}"
# Make the script executable
chmod +x /tmp/script.sh
# Execute the script
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