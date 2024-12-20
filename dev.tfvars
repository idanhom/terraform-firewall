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

# nsg_rules = [
#   {
#     name                       = "Allow_SSH"
#     priority                   = 100
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "22"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   },
#   {
#     name                       = "Allow_HTTP"
#     priority                   = 110
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "80"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   },
#   {
#     name                       = "Allow_Internet_Outbound"
#     priority                   = 200
#     direction                  = "Outbound"
#     access                     = "Allow"
#     protocol                   = "*"
#     source_port_range          = "*"
#     destination_port_range     = "*"
#     source_address_prefix      = "*"
#     destination_address_prefix = "0.0.0.0/0"
#   }
# ]


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


log_categories = [
  "AzureFirewallApplicationRule",
  "AzureFirewallNetworkRule"
]



log_analytics_saved_search = [
  {
    name         = "firewall_network_rules_take10"
    category     = "AzureFirewallNetworkRule"
    display_name = "Sample Network Rule Logs"
    query        = <<QUERY
AzureDiagnostics
| where Category == "AzureFirewallNetworkRule"
| take 10
QUERY
  },
  {
    name         = "firewall_application_rules_take10"
    category     = "AzureFirewallApplicationRule"
    display_name = "Sample Application Rule Logs"
    query        = <<QUERY
AzureDiagnostics
| where Category == "AzureFirewallApplicationRule"
| take 10
QUERY
  }
]

/* #access above search using az cli
az monitor log-analytics workspace saved-search show \
    --resource-group rg_project1 \
    --workspace-name firewalllaw \
    --name firewall_network_rules_take10
 */



# log_analytics_saved_search = [
#   {
#     name         = "Firewall_Network_Rules_Take10"
#     category     = "AzureFirewallNetworkRule"
#     display_name = "Sample Network Rule Logs"
#     query        = <<QUERY
# AzureDiagnostics
# | where Category == "AzureFirewallNetworkRule"
# | take 10
# QUERY
#   },
#   {
#     name         = "Firewall_Application_Rules_Take10"
#     category     = "AzureFirewallApplicationRule"
#     display_name = "Sample Application Rule Logs"
#     query        = <<QUERY
# AzureDiagnostics
# | where Category == "AzureFirewallApplicationRule"
# | take 10
# QUERY
#   },
#   {
#     name         = "Firewall_NAT_Rules_Take10"
#     category     = "AZFWNatRule"
#     display_name = "Sample NAT Rule Logs"
#     query        = <<QUERY
# AzureDiagnostics
# | where Category == "AZFWNatRule"
# | take 10
# QUERY
#   },
#   {
#     name         = "Firewall_Threat_Intelligence_Take10"
#     category     = "AZFWThreatIntel"
#     display_name = "Sample Threat Intelligence Logs"
#     query        = <<QUERY
# AzureDiagnostics
# | where Category == "AZFWThreatIntel"
# | take 10
# QUERY
#   },
#   {
#     name         = "Firewall_DNS_Proxy_Take10"
#     category     = "AzureFirewallDnsProxy"
#     display_name = "Sample DNS Proxy Logs"
#     query        = <<QUERY
# AzureDiagnostics
# | where Category == "AzureFirewallDnsProxy"
# | take 10
# QUERY
#   },
#   {
#     name         = "Firewall_DNS_Failures_Take10"
#     category     = "AZFWFqdnResolveFailure"
#     display_name = "Sample DNS Failure Logs"
#     query        = <<QUERY
# AzureDiagnostics
# | where Category == "AZFWFqdnResolveFailure"
# | take 10
# QUERY
#   }
# ]
