resource "azurerm_monitor_action_group" "action_group" {
  name                = "email-actiongroup"
  resource_group_name = azurerm_resource_group.example.name
  short_name          = "actiongroup"

  email_receiver {
    name                    = "First Lastname"
    email_address           = "john.doe@github.com"
    use_common_alert_schema = true
  }
}


resource "azurerm_monitor_metric_alert" "sql-dtu-alert" {
  name                     = "sql-dtu-usage"
  resource_group_name      = azurerm_resource_group.example.name
  target_resource_location = "West Europe"
  scopes                   = [azurerm_mssql_database.example.id]

  frequency   = "PT15M"
  #The evaluation frequency of this Metric Alert, represented in ISO 8601 duration format. Possible values are PT1M, PT5M, PT15M, PT30M and PT1H. Defaults to PT1M.
  window_size =  "PT30M"
  #window_size - (Optional) The period of time that is used to monitor alert activity, represented in ISO 8601 duration format. This value must be greater than frequency. Possible values are PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H and P1D. Defaults to PT5M.

  criteria {
    aggregation            = "Average"
    metric_name            = "dtu_consumption_percent"
    metric_namespace       = "Microsoft.Sql/servers/databases"
    operator               = "GreaterThan"
    skip_metric_validation = false
    threshold              = 75
  }

  action {
    action_group_id = azurerm_monitor_action_group.action_group.id
  }
  severity = 3
  #The severity of this Metric Alert. Possible values are 0, 1, 2, 3 and 4. Defaults to 3 (informational).
}