resource "azurerm_resource_group" "cloudshell" {
  count    = local.virtual_network_count
  name     = var.resource_name
  location = local.region
  tags     = var.tags
}
