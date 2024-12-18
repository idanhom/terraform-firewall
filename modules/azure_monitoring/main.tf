resource "azurerm_log_analytics_workspace" "firewall_logs" {
  name                = "firewalllaw"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = var.workspace_retention_in_days

  depends_on = [ var.firewall_id ]
}


resource "azurerm_monitor_diagnostic_setting" "firewall_diagnostics" {
  name                       = "firewall-diagnostic-setting"
  target_resource_id         = var.firewall_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.firewall_logs.id

  # Logs for network rules
  dynamic "enabled_log" {
    for_each = var.log_categories

    content {
      category = enabled_log.value
    }
  }
  depends_on = [ azurerm_log_analytics_workspace.firewall_logs, var.firewall_id ]
}

resource "azurerm_log_analytics_saved_search" "saved_search" {
  for_each = { for idx, search in var.log_analytics_saved_search : search.name => search }

  log_analytics_workspace_id = azurerm_log_analytics_workspace.firewall_logs.id

  name         = each.value.name
  category     = each.value.category
  display_name = each.value.display_name
  query        = each.value.query
}

# if issues with deployment, remove diagnostic settings in portal... until future solution

# https://learn.microsoft.com/en-us/azure/azure-monitor/logs/data-platform-logs
# https://learn.microsoft.com/en-us/azure/azure-monitor/logs/log-query-overview
# az monitor log-analytics workspace saved-search list \
#     --resource-group rg_project1 \
#     --workspace-name firewalllaw \
#     --query "[].{Name:name,Category:category,Query:query}" \
#     -o table
