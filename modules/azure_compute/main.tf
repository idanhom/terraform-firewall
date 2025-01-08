


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
  

  # adding data to install nginx. note: possibly won't work.
  # since firewall has (potentially blocking rules)
  # also, is file path correctly specified? missing azure_compute first
  custom_data = base64encode("./custom_data/nginx-install.base64")




   admin_username        = "adminuser"
   admin_password        = "Redeploy2025!!" # use key vault
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