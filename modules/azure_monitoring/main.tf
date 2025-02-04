resource "azurerm_log_analytics_workspace" "firewall_logs" {
  name                = "firewalllaw"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = var.workspace_retention_in_days
}

resource "azurerm_monitor_diagnostic_setting" "firewall_diagnostics" {
  name                       = "diagnostics-settings1"
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

# https://chatgpt.com/c/67a07aa3-3be8-800b-b1d7-a7f06609e769
# o3 dialog

# /* # │ Error: A resource with the ID "/subscriptions/***/resourceGroups/rg_project1/providers/Microsoft.Network/azureFirewalls/firewall|firewall-diagnostic-setting" already exists - to be managed via Terraform this resource needs to be imported into the State. Please see the resource documentation for "azurerm_monitor_diagnostic_setting" for more information.
# │ 
# │   with module.monitoring.azurerm_monitor_diagnostic_setting.firewall_diagnostics,
# │   on modules/azure_monitoring/main.tf line 16, in resource "azurerm_monitor_diagnostic_setting" "firewall_diagnostics":
# │   16: resource "azurerm_monitor_diagnostic_setting" "firewall_diagnostics */" {
# │ 
# ╵
# https://chatgpt.com/c/6784deb7-28d0-800b-b2ce-b173ce333f30



# Another issue?
# │ Error: creating Monitor Diagnostics Setting "diagnostics-settings1" for Resource "/subscriptions/***/resourceGroups/rg_project1/providers/Microsoft.Network/azureFirewalls/firewall": unexpected status 409 (409 Conflict) with response: {"code":"Conflict","message":"Data sink '/subscriptions/***/resourceGroups/rg_project1/providers/Microsoft.OperationalInsights/workspaces/firewalllaw' is already used in diagnostic setting 'diagnostics-settings' for category 'azurefirewallapplicationrule'. Data sinks can't be reused in different settings on the same category for the same resource."}
# │ 
# │   with module.monitoring.azurerm_monitor_diagnostic_setting.firewall_diagnostics,
# │   on modules/azure_monitoring/main.tf line 9, in resource "azurerm_monitor_diagnostic_setting" "firewall_diagnostics":
# │    9: resource "azurerm_monitor_diagnostic_setting" "firewall_diagnostics" {