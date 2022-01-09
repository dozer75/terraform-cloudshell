resource "azurerm_virtual_network" "cloudshell" {
  count               = local.virtual_network_count
  name                = var.resource_name
  location            = var.region
  resource_group_name = local.resource_group_name
  address_space       = [var.virtual_network_address]
  tags                = var.tags
}

resource "azurerm_subnet" "cloudshell" {
  name                 = "cloudshell"
  virtual_network_name = local.virtual_network_name
  resource_group_name  = local.resource_group_name
  address_prefixes     = [var.virtual_network_cloudshell_subnet_address]
  service_endpoints    = ["Microsoft.Storage"]

  delegation {
    name = "CloudShellDelegation"

    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet" "relay" {
  name                                           = "relay"
  virtual_network_name                           = local.virtual_network_name
  resource_group_name                            = local.resource_group_name
  enforce_private_link_endpoint_network_policies = true
  address_prefixes                               = [var.virtual_network_relay_subnet_address]
}

resource "azurerm_subnet" "storage" {
  name                                           = "storage"
  virtual_network_name                           = local.virtual_network_name
  resource_group_name                            = local.resource_group_name
  enforce_private_link_endpoint_network_policies = false
  address_prefixes                               = [var.virtual_network_storage_subnet_address]
  service_endpoints                              = ["Microsoft.Storage"]
}

resource "azurerm_private_dns_zone_virtual_network_link" "servicebus" {
  name                  = "servicebus"
  resource_group_name   = local.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.servicebus.name
  virtual_network_id    = local.virtual_network_id
  tags                  = var.tags
}
