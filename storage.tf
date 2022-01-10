resource "azurerm_storage_account" "cloudshell" {
  name                     = "${replace(var.resource_name, "/-|_/", "")}${coalesce(var.resource_suffix, random_string.resource_suffix.result)}"
  resource_group_name      = local.resource_group_name
  location                 = local.region
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Cool"
  min_tls_version          = "TLS1_2"
  allow_blob_public_access = true
  tags                     = var.tags
}

resource "azurerm_storage_share" "cloudshell" {
  name                 = "cloudshell"
  storage_account_name = azurerm_storage_account.cloudshell.name
  quota                = 6
}

resource "azurerm_storage_account_network_rules" "default" {
  storage_account_id         = azurerm_storage_account.cloudshell.id
  bypass                     = ["None"]
  default_action             = "Deny"
  virtual_network_subnet_ids = [azurerm_subnet.cloudshell.id, azurerm_subnet.storage.id]
  ip_rules                   = ["${chomp(data.http.myip.body)}"]

  depends_on = [
    azurerm_storage_account.cloudshell,
    azurerm_storage_share.cloudshell
  ]
}
