variable "environment" {
  description = "Environment name. Will be used along with `project_name` as a prefix for all resources."
  type        = string
}

variable "project_name" {
  description = "Project name. Will be used along with `environment` as a prefix for all resources."
  type        = string
}

variable "azure_location" {
  description = "Azure location in which to launch resources."
  type        = string
}

variable "key_vault_access_ipv4" {
  description = "List of IPv4 Addresses that are permitted to access the Key Vault"
  type        = list(string)
}

variable "tfvars_filename" {
  description = "tfvars filename. This file is uploaded and stored encrypted within Key Vault, to ensure that the latest tfvars are stored in a shared place."
  type        = string
}

variable "registry_sku" {
  description = "The registry SKU. To create Private Endpoints, 'Premium' is required."
  type        = string
  default     = "Basic"
}

variable "registry_admin_enabled" {
  description = " Specifies whether the admin user is enabled"
  type        = bool
  default     = false
}

variable "registry_public_access_enabled" {
  description = "hether public network access is allowed for the container registry"
  type        = bool
  default     = false
}

variable "registry_retention_days" {
  description = "The number of days to retain an untagged manifest after which it gets purged."
  type        = number
  default     = 7
}

variable "registry_network_allowed_ip_ranges" {
  description = "Allowed IP ranges for the registry"
  type        = list(string)
  default     = []
}

variable "private_endpoint_configutations" {
  description = <<EOT
  Map of private endpoint configurations, specifying the VNet name/resource-group and a new subnet CIDR. A subnet, private endpoint and DNS zone will be created within the specified VNet.
  {
    endpoint-name = {
      vnet_name: The Name of the VNet to create the private endpoint resources
      vnet_resource_group_name: The Name of the resource group containing the VNet
      subnet_cidr: THe CIDR of the Private Endpoint subnet to be created
      route_table_name: The Route Table ID to associate the subnet with (Optional)
    }
  }
  EOT
  type = map(object({
    vnet_name                       = string
    vnet_resource_group_name        = string
    subnet_cidr                     = string
    subnet_route_table_name         = optional(string, null)
    create_acr_privatelink_dns_zone = optional(bool, true)
  }))
  default = {}
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default     = {}
}
