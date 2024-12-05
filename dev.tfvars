resource_group_name = "rg_project"
location            = "North Europe"

vnets = {
  vnet1 = {
    vnet_name     = "vnet1"
    vnet_prefix   = ["10.0.0.0/16"]
    subnet_name   = "subnet1"
    subnet_prefix = ["10.0.1.0/24"]

    nic_name = "nic1"
  } 

  vnet2 = {
    vnet_name     = "vnet2"
    vnet_prefix   = ["10.1.0.0/16"]
    subnet_name   = "subnet2"
    subnet_prefix = ["10.1.1.0/24"]

    nic_name = "nic2"
  }
}

//make the afw vars into map, revise in root main.tf (others too?)

firewall_vnet_name   = "FWVnet"
firewall_vnet_prefix = ["10.2.0.0/16"]

firewall_subnet_name   = "AzureFirewallSubnet"
firewall_subnet_prefix = ["10.2.2.0/24"]

firewall_ip_name = "firewall_pip"
firewall_name    = "firewall"

/* afw = {
firewall_vnet_name   = "FWVnet"
firewall_vnet_prefix = ["10.2.0.0/16"]

firewall_subnet_name   = "AzureFirewallSubnet"
firewall_subnet_prefix = ["10.2.2.0/24"]

firewall_ip_name = "firewall_pip"
firewall_name    = "firewall"
}
 */