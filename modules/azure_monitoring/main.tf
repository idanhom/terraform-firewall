# https://chatgpt.com/g/g-pDLabuKvD-terraform-guide/c/67625f31-a9a0-800b-a321-f69b681e3bc3



resource "azurerm_log_analytics_workspace" "firewall_logs" {
  name                = "firewalllaw"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = var.workspace_retention_in_days
}


resource "azurerm_monitor_diagnostic_setting" "firewall_diagnostics" {
  name                       = "firewall-diagnostic-setting"
  target_resource_id         = var.target_resource_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.firewall_logs.id

  # Logs for network rules
  dynamic "enabled_log" {
    for_each = var.log_categories

    content {
      category = enabled_log.value
    }
  }
}

resource "azurerm_log_analytics_saved_search" "saved_search" {
  for_each = { for idx, search in var.log_analytics_saved_search : search.name => search }

  log_analytics_workspace_id = azurerm_log_analytics_workspace.firewall_logs.id

  name         = each.value.name
  category     = each.value.category
  display_name = each.value.display_name
  query        = each.value.query
}
