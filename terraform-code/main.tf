terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.94.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
  }
}
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "tf-resource-group"
  location = "West Europe"
}
resource "random_password" "server-name" {
  length  = 6
  special = false
  lower   = false
}

resource "random_password" "admin-pw" {
  length  = 32
  special = false
  lower   = true
}

resource "azurerm_mssql_server" "example" {
  name                         = "myazuresqlserver-${lower(random_password.server-name.result)}"
  resource_group_name          = azurerm_resource_group.example.name
  location                     = azurerm_resource_group.example.location
  version                      = "12.0"
  administrator_login          = "SuperAdmin"
  administrator_login_password = random_password.admin-pw.result
  minimum_tls_version          = "1.2"

}


resource "azurerm_mssql_database" "example" {
  name           = "mydatabase-${lower(random_password.server-name.result)}"
  server_id      = azurerm_mssql_server.example.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  sku_name       = "Basic"

}

resource "azurerm_mssql_firewall_rule" "example" {
  name             = "AllowAppService"
  server_id        = azurerm_mssql_server.example.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}
resource "azurerm_service_plan" "example" {
  name                = "myserviceplan-${lower(random_password.server-name.result)}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku_name            = "S3"
  os_type             = "Windows"

}

resource "azurerm_windows_web_app" "example" {
  name                = "my-app-${lower(random_password.server-name.result)}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_service_plan.example.location
  service_plan_id     = azurerm_service_plan.example.id
  site_config {}
}


output "SQLAdminPWD" {
    value = nonsensitive(random_password.admin-pw.result)
}

output "SQLUserName" {
    value = "SuperAdmin"
}
output "AppUrl" {
    value = azurerm_windows_web_app.example.default_hostname
}
