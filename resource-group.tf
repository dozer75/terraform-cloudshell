resource "azurerm_resource_group" "cloudshell" {
  name     = var.resource_name
  location = var.region
  tags     = var.tags
}
