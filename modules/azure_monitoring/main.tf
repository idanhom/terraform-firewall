resource "azurerm_log_analytics_workspace" "firewall_logs" {
  name                = "firewalllaw"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = var.workspace_retention_in_days

  depends_on = [var.firewall_id]
}






resource "azurerm_monitor_diagnostic_setting" "firewall_diagnostics" {
  name                       = "${var.firewall_id}-diagnostics"
  target_resource_id         = var.firewall_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.firewall_logs.id

/*   # Dynamically enable logs
  dynamic "enabled_log" {
    for_each = var.log_categories

    content {
      category = enabled_log.value
    }
  }
 */
  metric {
    category = "azurefirewallapplicationrule"
    enabled = true
  }


  metric {
    category = "azurefirewallnetworkrule"
    enabled = true
  }


  metric {
    category = "azurefirewalldnsproxy"
    enabled = true
  }

/*   metric {
    category = "AllMetrics"
    enabled  = true
  }
 */
  depends_on = [
    azurerm_log_analytics_workspace.firewall_logs,
    var.firewall_id
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



# │ Error: A resource with the ID "/subscriptions/***/resourceGroups/rg_project1/providers/Microsoft.Network/azureFirewalls/firewall|firewall-diagnostic-setting" already exists - to be managed via Terraform this resource needs to be imported into the State. Please see the resource documentation for "azurerm_monitor_diagnostic_setting" for more information.
# │ 
# │   with module.monitoring.azurerm_monitor_diagnostic_setting.firewall_diagnostics,
# │   on modules/azure_monitoring/main.tf line 16, in resource "azurerm_monitor_diagnostic_setting" "firewall_diagnostics":
# │   16: resource "azurerm_monitor_diagnostic_setting" "firewall_diagnostics" {
# │ 
# ╵
# https://chatgpt.com/c/6784deb7-28d0-800b-b2ce-b173ce333f30



/* 
resource "azurerm_log_analytics_saved_search" "saved_search" {
  for_each = var.log_analytics_saved_search

  log_analytics_workspace_id = azurerm_log_analytics_workspace.firewall_logs.id

  name         = each.key
  category     = each.value.category
  display_name = each.value.display_name
  query        = each.value.query
}
 */


