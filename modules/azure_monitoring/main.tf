resource "azurerm_log_analytics_workspace" "firewall_logs" {
  name                = "${var.resource_group_name}-law"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = var.workspace_retention_in_days
}


resource "azurerm_monitor_diagnostic_setting" "firewall_diagnostics" {
  name               = "firewall-diagnostic-setting"
  target_resource_id = var.firewall_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.firewall_logs.id


    enabled_log {
      category = 


    }


}