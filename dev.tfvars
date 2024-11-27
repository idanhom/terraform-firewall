resource_group_name = "rg_project"
location            = "North Europe"

#before making map of vnets and subnets
# vnet_name           = "my_vnet"
# vnet_prefix         = ["10.0.0.0/16"]

# subnets = {
#   subnet1 = "10.0.1.0/24"
#   subnet2 = "10.0.2.0/24"
# }

vnets = {
  vnet1 = {
    vnet_name = "vnet1"
    vnet_prefix = ["10.0.0.0/16"]
    subnet_name = "subnet1"
    subnet_prefix = ["10.0.1.0/24"]
  }

  vnet2 = {
    vnet_name = "vnet2"
    vnet_prefix = ["10.1.0.0/16"]
    subnet_name = "subnet2"
    subnet_prefix = ["10.1.1.0/24"]
  }

  # note, this should be broken out, since that means I can add more variables (vm) to the deployment.
  # fits better with each.value.vm_name etc. and then fw is separate.
  
}

firewall = {
    firewall_name= "FWVnet"
    firewall_vnet_prefix = ["10.2.0.0/16"]

    firewall_subnet_name = "AzureFirewallSubnet"
    firewall_subnet_prefix = ["10.2.2.0/24"]
      
    firewall_ip_name = "firewall_pip"
    firewall_name    = "firewall"
  }

nic_name = {
  subnet1 = "nic1"
  subnet2 = "nic2"
}

