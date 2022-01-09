variable "tenant_id" {
  description = "The id of the tenant used by this base scripting."
}

variable "subscription_id" {
  description = "The id of the subscription used by this base scripting."
}

variable "region" {
  default     = ""
  description = "Default region of base resources."
}

variable "resource_name" {
  default     = "cloudshell"
  description = "The default base sname of all resources."
}

variable "resource_suffix" {
  default     = ""
  type        = string
  description = "The prefix for all resources that needs a unique name, defaults to random string if not specified."
}

variable "tags" {
  default     = {}
  description = "Tags to mark all resources."
}

variable "virtual_network_resource_group_name" {
  default     = ""
  description = "The resource group name of virtual_network_name. Read the README.md before doing this to ensure this correctly."
}

variable "virtual_network_name" {
  default     = ""
  description = "An existing virtual network name. Read the README.md before doing this to ensure this correctly."
}

variable "virtual_network_address" {
  default     = "192.168.0.0/24"
  description = "The address space for the base Virtual Network."
}

variable "virtual_network_cloudshell_subnet_address" {
  default     = "192.168.0.64/26"
  description = "The subnet for the cloudshell subnet of the base Virtual Network."
}

variable "virtual_network_relay_subnet_address" {
  default     = "192.168.0.128/26"
  description = "The subnet for the relay subnet of the base Virtual Network."
}

variable "virtual_network_storage_subnet_address" {
  default     = "192.168.0.192/26"
  description = "The subnet for the storage subnet of the base Virtual Network."
}
