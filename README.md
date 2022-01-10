# Cloudshell with Azure private Virtual Network

This project utilize the Terraform project model to create a complete environment that is enabled to run Azure Cloud Shell in a private Virtual Network.

The Terraform project can both connect to an existing Virtual Network or create a whole new environment that is isolated as a Cloud Shell environment.

## Background

By default an Azure Cloud Shell session runs in a Microsoft Azure network separate from your other resources. This causes issues if you want to access/configure resources in your Azure environment that is not publicly accessible like e.g. a Virtual Machine with private IP or a storage account that is locked down.

To encounter this issue Microsoft has made it possible to set up an environment that enables the Cloud Shell to communicate with other resources using a Virtual Network.

## Applying Terraform project

### Prerequisites

An environment to run Terraform projects against Azure. Refer to the [Terraform on Azure documentation](https://docs.microsoft.com/en-us/azure/developer/terraform/) and the `Get started` for more information on how to set up Terraform for Azure in different environments.

> If Cloud Shell has been used in the past or when executing this terraform project, the existing cloud drive must be unmounted. To do this run `clouddrive unmount` from an active Cloud Shell session after the terraform has been done.

### Azure Container Instance Service

The Azure Container Instance Resource provider needs to be registered in the subscription that holds the Virtual Network you want to use.

Register this using:
* Azure CLI
  * `az provider register --namespace Microsoft.ContainerInstance`
* Azure PowerShell
  * `Register-AzResourceProvider -ProviderNamespace Microsoft.ContainerInstance.`

### Required variables

To be able to execute this terraform project, you need to set the following required variables

* `tenant_id`
  * The id of the tenant for your Azure account
* `subscription_id`
  * The id of the subscription where you want the resources to live

#### Required when using existing Virtual Network

* `virtual_network_name`
  * Required if the Cloud Shell should connect to an existing Virtual Network
  * The name of the existing Virtual Network
* `virtual_network_resource_group_name`
  * Required if `virtual_network_name` is specified.
  * The name of the resource group where `virtual_network_name` exists.
* `virtual_network_cloudshell_subnet_address`, `virtual_network_relay_subnet_address`, `virtual_network_storage_subnet_address` 
  * Needs to be defined with subnet CIDR that is valid within the existing Virtual Network.

#### Required when creating an isolated Cloud Shell environment (no existing Virtual Network)

* `region`
  * The Azure region you want to locate the cloud shell environment
  * All Cloud shell primary regions except the one below is currently supported
    * Azure Central India (Azure Cloud Shell limitation)
    * Azure Germany (may work, not tested)
    * Azure US Government (not implemented)

### Optional variables

In addition to the required variables there is several optional variables as well

* `resource_name`
  * The default name of all resources that is create is `cloudshell`, to override this set the `resource_name` variable.
* `resource_suffix`
  * Certain resources requires to have unique name. By default, the unique name is a combination of `resource_name` and a 8 character suffix. To override this suffix set the `resource_suffix` parameter. The combination `resource_name` and `resource_suffix` must be guaranteed unique for the Azure Storage and Azure Relay services used.
* `tags`
  * Optional tags that can be added to the environment

#### Optional when creating an isolated Cloud Shell environment (no existing Virtual Network)

* `virtual_network_address`, `virtual_network_cloudshell_subnet_address`, `virtual_network_relay_subnet_address`, `virtual_network_storage_subnet_address` 
  * By default the ip configuration of the Virtual Network for the cloud shell is based on the `192.168.0.0/24` class c address range. Override this by using these variables.

### Apply terraform script

1. Clone this project to a local folder
2. Set the required and optional variables
   * See required and optional variables section for the required and optional based desired configuration.
   * Refer to Terraform documentation on [setting variables](https://www.terraform.io/language/values/variables#assigning-values-to-root-module-variables).
3. Run the `terraform apply` command, review the changes an confirm the changes by entering `yes` when questioned.

### Output

When the terraform operation is done, the project returns the following parameters

* `vnetid`
  * The resource id of the newly created virtual net. Use this to peer this network to other Virtual Networks where the Cloud Shell should have access to resources.

## Further usage

When this Terraform project is applied you will need to connect it to the Cloud Shell. 

To do this you need to follow the following steps:
1. Open the Cloud Shell in the portal or following this [link](https://shell.azure.com).
2. Select either `Bash` or `PowerShell`.
3. On the `You have no storage mounted` page select `Show advanced settings` and the `Show VNET isolation settings`.
4. In `Cloud Shell Region` select the same region as you configured with the `region` variable.
   * Normally this should be set accordingly, but for some reason when selecting the `Show VNET isolation settings` variable the region is changed to `Australia Central` secondary region (unsupported). See this [bug](https://github.com/Azure/CloudShell/issues/130) for more information.
5. In the `Resource group` select the group that was created by the script (the same name as the `resource_name` variable).
   * Normally, this should fill out all other parameters like `Storage account`, `Virtual network`, `Network profile` and `Relay namespace`, but if it doesn't you will notice that the three latter parameters is disabled. If this is the case, switch the resource group to a another and back and the parameters should be filled accordingly. See this [bug](https://github.com/Azure/CloudShell/issues/131) for more information.
6. In the `File share` enter the `cloudshell` as the share name (this is created during the terraform).

You will now have a Cloud Shell attached either to a Virtual Network that you specified or you can peer the newly created Virtual Network with other Virtual Networks for accessing these.

### Usage tips

When working with other Terraform projects you should peer this Virtual Network to the one in those Terraform projects. Be sure that resources that isn't publicly accessible has a `depends_on` the peering configuration like this.

```
# The cloudshell Virtual Network peering
resource "azurerm_virtual_network_peering" "cloudshell_peering" {
    # ...
}

# Denies external access and connect the storage to the storage Virtual Network.
resource "azurerm_storage_account_network_rules" "allow_virtual" {
  storage_account_id         = azurerm_storage_account.storage.id
  bypass                     = ["None"]
  default_action             = "Deny"
  virtual_network_subnet_ids = [azurerm_subnet.storage.id]

  depends_on = [
    # Ensure that the peering is created before this resource is created.
    azurerm_virtual_network_peering.peering
  ]
}
```