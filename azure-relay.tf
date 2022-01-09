resource "azurerm_relay_namespace" "cloudshell" {
  name                = "cloudshell-${coalesce(var.resource_suffix, random_string.resource_suffix.result)}"
  resource_group_name = azurerm_resource_group.cloudshell.name
  location            = var.region
  sku_name            = "Standard"
  tags                = var.tags
}

resource "azurerm_role_assignment" "cloudshell" {
  role_definition_name = "Contributor"
  scope                = azurerm_relay_namespace.cloudshell.id
  principal_id         = data.azuread_service_principal.container_instance.object_id
}

resource "azurerm_private_endpoint" "cloudshell" {
  name                = "cloudshell"
  resource_group_name = azurerm_resource_group.cloudshell.name
  location            = var.region
  subnet_id           = azurerm_subnet.relay.id
  tags                = var.tags
  
  private_service_connection {
    name                           = "cloudshell"
    private_connection_resource_id = azurerm_relay_namespace.cloudshell.id
    subresource_names              = ["namespace"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_dns_a_record" "cloudshell" {
  name                = azurerm_relay_namespace.cloudshell.name
  zone_name           = azurerm_private_dns_zone.servicebus.name
  resource_group_name = azurerm_resource_group.cloudshell.name
  ttl                 = 300
  records             = azurerm_private_endpoint.cloudshell.custom_dns_configs[0].ip_addresses
}
