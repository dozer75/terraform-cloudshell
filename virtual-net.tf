resource "azurerm_virtual_network" "cloudshell" {
  name                = var.resource_name
  location            = var.region
  resource_group_name = azurerm_resource_group.cloudshell.name
  address_space       = [var.virtual_network_address]
  tags                = var.tags
}

resource "azurerm_subnet" "cloudshell" {
  name                 = "cloudshell"
  virtual_network_name = azurerm_virtual_network.cloudshell.name
  resource_group_name  = azurerm_resource_group.cloudshell.name
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
  virtual_network_name                           = azurerm_virtual_network.cloudshell.name
  resource_group_name                            = azurerm_resource_group.cloudshell.name
  enforce_private_link_endpoint_network_policies = true
  address_prefixes                               = [var.virtual_network_relay_subnet_address]
}

resource "azurerm_subnet" "storage" {
  name                                           = "storage"
  virtual_network_name                           = azurerm_virtual_network.cloudshell.name
  resource_group_name                            = azurerm_resource_group.cloudshell.name
  enforce_private_link_endpoint_network_policies = false
  address_prefixes                               = [var.virtual_network_storage_subnet_address]
  service_endpoints                              = ["Microsoft.Storage"]
}

resource "azurerm_private_dns_zone_virtual_network_link" "servicebus" {
  name                  = "servicebus"
  resource_group_name   = azurerm_resource_group.cloudshell.name
  private_dns_zone_name = azurerm_private_dns_zone.servicebus.name
  virtual_network_id    = azurerm_virtual_network.cloudshell.id
  tags                  = var.tags
}
