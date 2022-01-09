output "vnetId" {
    value = azurerm_virtual_network.cloudshell.id
    description = "The id of the cloudshell vnet"
}
