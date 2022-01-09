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
      source = "hashicorp/http"
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
