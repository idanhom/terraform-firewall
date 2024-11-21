resource_group_name = "rg_project"
location            = "North Europe"
vnet_name           = "my_vnet"
vnet_prefix         = ["10.0.0.0/16"]

subnets = {
  subnet1 = "10.0.1.0/24"
  subnet2 = "10.0.1.0/24"
}

# subnet_name           = ["subnet1", "subnet2"]
# subnet_address_prefix = ["10.0.1.0/24", "10.0.2.0/24"]

firewall_ip_name = "firewall_pip"
firewall_name    = "firewall"


firewall_subnet_prefix = ["10.0.3.0/24"]

nic_name = {
  subnet1 = "nic1"
  subnet2 = "nic2"
}