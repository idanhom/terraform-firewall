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


# To implement saved_search
# https://chatgpt.com/g/g-pDLabuKvD-terraform-guide/c/67614e92-8aa0-800b-8451-31f946fe9aad