resource "azurerm_log_analytics_workspace" "firewall_logs" {
  name                = "firewalllaw"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = var.workspace_retention_in_days
}

resource "azurerm_monitor_diagnostic_setting" "firewall_diagnostics" {
  name                       = "diagnostics-settings"
  target_resource_id         = var.firewall_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.firewall_logs.id


  // Enable logs for specific categories
  enabled_log {
    category = "azurefirewallapplicationrule"
  }

  enabled_log {
    category = "azurefirewallnetworkrule"
  }

  enabled_log {
    category = "azurefirewalldnsproxy"
  }

  // Enable metrics
  metric {
    category = "AllMetrics"
    enabled  = true
  }

  depends_on = [
    azurerm_log_analytics_workspace.firewall_logs
  ]
}

resource "azurerm_log_analytics_query_pack" "firewall_pack" {
  name                = "firewall-query-pack"
  resource_group_name = var.resource_group_name
  location            = var.location
}

# Example of adding a single query
resource "azurerm_log_analytics_query_pack_query" "fw_network_rule_query" {
  query_pack_id = azurerm_log_analytics_query_pack.firewall_pack.id
  display_name  = "Sample Network Rule Logs"
  description   = "Show the last 50 firewall network rule logs"
  body          = <<EOT
AzureDiagnostics
| where Category == "AzureFirewallNetworkRule"
| order by TimeGenerated desc
| limit 50
EOT
}
