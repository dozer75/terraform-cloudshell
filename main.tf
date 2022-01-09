terraform {

  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~>2.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~>2.1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.1.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "azuread" {
  tenant_id = var.tenant_id
}

provider "http" {
}

provider "random" {
}

data "azurerm_client_config" "current" {}

data "azurerm_virtual_network" "current" {
  count               = local.virtual_network_count == 1 ? 0 : 1
  name                = var.virtual_network_name
  resource_group_name = var.virtual_network_resource_group_name
}

data "azuread_client_config" "current" {}

data "azuread_service_principal" "container_instance" {
  display_name = "Azure Container Instance Service"
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "random_string" "resource_suffix" {
  length  = 8
  special = false
  lower   = true
  upper   = false
}

locals {
  region                = var.virtual_network_name != "" ? data.azurerm_virtual_network.current[0].location : var.region
  resource_group_name   = var.virtual_network_name != "" ? data.azurerm_virtual_network.current[0].resource_group_name : azurerm_resource_group.cloudshell[0].name
  virtual_network_count = var.virtual_network_name != "" ? 0 : 1
  virtual_network_id    = var.virtual_network_name != "" ? data.azurerm_virtual_network.current[0].id : azurerm_virtual_network.cloudshell[0].id
  virtual_network_name  = var.virtual_network_name != "" ? data.azurerm_virtual_network.current[0].name : azurerm_virtual_network.cloudshell[0].name
}
