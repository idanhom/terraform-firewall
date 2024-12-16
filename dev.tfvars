resource_group_name = "rg_project1"
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

afw = {
  firewall_vnet_name   = "FWVnet"
  firewall_vnet_prefix = ["10.2.0.0/16"]

  firewall_subnet_name   = "AzureFirewallSubnet"
  firewall_subnet_prefix = ["10.2.2.0/24"]

  firewall_ip_name = "firewall_pip"
  firewall_name    = "firewall"
}

vnet_route_table = {
  vnet1 = {
    internet_traffic = {
      name           = "internet_traffic"
      address_prefix = "0.0.0.0/0" # CIDR for Internet
      next_hop_type  = "VirtualAppliance"
    }
    vnet_to_vnet = {
      name           = "SpokeToSpokeTraffic"
      address_prefix = "10.1.0.0/16" # CIDR for vnet2
      next_hop_type  = "VirtualAppliance"
    }
  }
  vnet2 = {
    internet_traffic = {
      name           = "internet_traffic"
      address_prefix = "0.0.0.0/0" # CIDR for Internet
      next_hop_type  = "VirtualAppliance"
    }
    vnet_to_vnet = {
      name           = "SpokeToSpokeTraffic"
      address_prefix = "10.0.0.0/16" # CIDR for vnet1
      next_hop_type  = "VirtualAppliance"
    }
  }
}







