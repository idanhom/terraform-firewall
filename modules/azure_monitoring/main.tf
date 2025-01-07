# Read up on the following:
# https://chatgpt.com/g/g-OJCk3Ji0a-azure-solutions-guide/c/676e888a-4114-800b-9a8a-5f03ca95e659
# before i proceed with the saved_search problem, try the query in the portal, so i know it works.

resource "azurerm_log_analytics_workspace" "firewall_logs" {
  name                = "firewalllaw"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = var.workspace_retention_in_days

  depends_on = [ var.firewall_id ]
}



# Note: IS THE DIAGNOSTICS SETTINGS EVEN CORRECT GIVEN MY USECASE?
resource "azurerm_monitor_diagnostic_setting" "firewall_diagnostics" {
  name                       = "firewall-diagnostic-setting"
  target_resource_id         = var.firewall_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.firewall_logs.id

  # Dynamically enable logs
  dynamic "enabled_log" {
    for_each = var.log_categories

    content {
      category = enabled_log.value
    }
  }

  # Metrics
  metric {
    category = "AllMetrics"
    enabled  = true
  }

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
  display_name                = "Sample Network Rule Logs"
  description                 = "Show the last 50 firewall network rule logs"
  body                        = <<EOT
AzureDiagnostics
| where Category == "AzureFirewallNetworkRule"
| order by TimeGenerated desc
| limit 50
EOT
}




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


