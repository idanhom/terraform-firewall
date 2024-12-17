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

log_categories = [ 
  "AzureFirewallNetworkRule", # Monitor traffic based on IP addresses and ports.
  "AzureFirewallApplicationRule", # Monitor traffic based on FQDN (domains) and protocols (HTTP/HTTPS).
  "AZFWNatRule", # Track and verify inbound traffic using DNAT rules.
  "AZFWThreatIntel", # Detect and log malicious traffic from threat feeds.
  "AzureFirewallDnsProxy", # Monitor DNS resolutions and troubleshoot DNS issues.
  "AZFWFqdnResolveFailure" # Troubleshoot DNS failures in domain-based application rules.
]

log_analytics_saved_search = [
  {
    name         = "Firewall_InterVNet_Traffic"
    category     = "AzureFirewallNetworkRule"
    display_name = "Inter-VNet Traffic Through Firewall"
    query        = <<QUERY
AzureDiagnostics
| where Category == "AzureFirewallNetworkRule"
| where SourceIP startswith "10." and DestinationIP startswith "10."
| project TimeGenerated, SourceIP, DestinationIP, Action, Protocol, RuleName
| sort by TimeGenerated desc
QUERY
  },
  {
    name         = "Firewall_Inbound_Internet"
    category     = "AzureFirewallNetworkRule"
    display_name = "Inbound Internet Traffic to VMs"
    query        = <<QUERY
AzureDiagnostics
| where Category == "AzureFirewallNetworkRule"
| where SourceIP !startswith "10." and DestinationIP startswith "10."
| project TimeGenerated, SourceIP, DestinationIP, Action, Protocol, RuleName
| sort by TimeGenerated desc
QUERY
  },
  {
    name         = "Firewall_Outbound_Internet"
    category     = "AzureFirewallNetworkRule"
    display_name = "Outbound Internet Traffic from VMs"
    query        = <<QUERY
AzureDiagnostics
| where Category == "AzureFirewallNetworkRule"
| where SourceIP startswith "10." and DestinationIP !startswith "10."
| project TimeGenerated, SourceIP, DestinationIP, Action, Protocol, RuleName
| sort by TimeGenerated desc
QUERY
  },
  {
    name         = "Firewall_Denied_Traffic"
    category     = "AzureFirewallNetworkRule"
    display_name = "Denied Traffic Logs"
    query        = <<QUERY
AzureDiagnostics
| where Category == "AzureFirewallNetworkRule"
| where Action == "Deny"
| project TimeGenerated, SourceIP, DestinationIP, Protocol, RuleName, Action
| sort by TimeGenerated desc
QUERY
  },
  {
    name         = "Firewall_ThreatIntel_Logs"
    category     = "AZFWThreatIntel"
    display_name = "Firewall Threat Intelligence Logs"
    query        = <<QUERY
AzureDiagnostics
| where Category == "AZFWThreatIntel"
| project TimeGenerated, SourceIP, DestinationIP, ThreatDescription, Action
| sort by TimeGenerated desc
QUERY
  },
  {
    name         = "Firewall_DNS_Failures"
    category     = "AZFWFqdnResolveFailure"
    display_name = "Firewall DNS Resolution Failures"
    query        = <<QUERY
AzureDiagnostics
| where Category == "AZFWFqdnResolveFailure"
| project TimeGenerated, Fqdn, FailureReason, Action
| sort by TimeGenerated desc
QUERY
  },
  {
    name         = "Firewall_DNS_Proxy_Logs"
    category     = "AzureFirewallDnsProxy"
    display_name = "Firewall DNS Proxy Logs"
    query        = <<QUERY
AzureDiagnostics
| where Category == "AzureFirewallDnsProxy"
| project TimeGenerated, SourceIP, DestinationIP, Fqdn, Action
| sort by TimeGenerated desc
QUERY
  },
  {
    name         = "Firewall_NAT_Rule_Traffic"
    category     = "AZFWNatRule"
    display_name = "Firewall NAT Rule Traffic Logs"
    query        = <<QUERY
AzureDiagnostics
| where Category == "AZFWNatRule"
| project TimeGenerated, SourceIP, DestinationIP, TranslatedIP, Action
| sort by TimeGenerated desc
QUERY
  }
]
