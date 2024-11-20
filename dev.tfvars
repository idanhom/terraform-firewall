resource_group_name = "rg_project"
location            = "North Europe"
vnet_name           = "my_vnet"
vnet_prefix         = ["10.0.0.0/16"]

subnet_name           = ["subnet1", "subnet2"]
subnet_address_prefix = ["10.0.1.0/24", "10.0.2.0/24"]

//firewall_subnet_name = "AzureFirewallSubnet" not needed as fw subnet accepts only one name
firewall_ip_name     = "firewall_pip"
firewall_name        = "firewall"


firewall_subnet_prefix = ["10.0.3.0/24"]

nic_name = ["nic1", "nic2"]