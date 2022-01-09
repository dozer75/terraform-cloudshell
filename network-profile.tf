resource "azurerm_network_profile" "container_instance" {
  name                = "azure-container-instance"
  location            = local.region
  resource_group_name = local.resource_group_name
  tags                = var.tags

  container_network_interface {
    name = "eth-${azurerm_subnet.cloudshell.name}"
    ip_configuration {
      name      = "ipconfig-${azurerm_subnet.cloudshell.name}"
      subnet_id = azurerm_subnet.cloudshell.id
    }
  }
}

resource "azurerm_role_assignment" "container_instance" {
  role_definition_name = "Network Contributor"
  scope                = azurerm_network_profile.container_instance.id
  principal_id         = data.azuread_service_principal.container_instance.object_id
}
