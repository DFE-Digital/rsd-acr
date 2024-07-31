# Azure Container Registry for RSD

[![Terraform CI](https://github.com/DFE-Digital/rsd-acr/actions/workflows/continuous-integration-terraform.yml/badge.svg?branch=main)](https://github.com/DFE-Digital/rsd-acr/actions/workflows/continuous-integration-terraform.yml?branch=main)

This project creates and manages Azure Container Registries for RSD.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.5 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.98.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.98.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_azurerm_key_vault"></a> [azurerm\_key\_vault](#module\_azurerm\_key\_vault) | github.com/DFE-Digital/terraform-azurerm-key-vault-tfvars | v0.4.1 |

## Resources

| Name | Type |
|------|------|
| [azurerm_container_registry.acr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry) | resource |
| [azurerm_container_registry_scope_map.rw-all](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry_scope_map) | resource |
| [azurerm_container_registry_task.untagged](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry_task) | resource |
| [azurerm_private_dns_zone.acr_private_link](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.acr_private_link](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_endpoint.acr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_resource_group.acr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.acr_pull](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.acr_push](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_subnet.acr_private_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_route_table_association.acr_private_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association) | resource |
| [azurerm_user_assigned_identity.acr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [null_resource.acr_build](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [azurerm_route_table.private_endpoints](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/route_table) | data source |
| [azurerm_virtual_network.private_endpoints](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assign_acrpull_role_to_uami"></a> [assign\_acrpull\_role\_to\_uami](#input\_assign\_acrpull\_role\_to\_uami) | Assign the AcrPull role to the ACR Identity | `bool` | `false` | no |
| <a name="input_assign_acrpush_role_to_uami"></a> [assign\_acrpush\_role\_to\_uami](#input\_assign\_acrpush\_role\_to\_uami) | Assign the AcrPush role to the ACR Identity | `bool` | `false` | no |
| <a name="input_azure_location"></a> [azure\_location](#input\_azure\_location) | Azure location in which to launch resources. | `string` | n/a | yes |
| <a name="input_enable_weekly_purge_task"></a> [enable\_weekly\_purge\_task](#input\_enable\_weekly\_purge\_task) | Launch a weekly ACR task that untags and removes any container images that are not attached to Container Apps | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name. Will be used along with `project_name` as a prefix for all resources. | `string` | n/a | yes |
| <a name="input_key_vault_access_ipv4"></a> [key\_vault\_access\_ipv4](#input\_key\_vault\_access\_ipv4) | List of IPv4 Addresses that are permitted to access the Key Vault | `list(string)` | n/a | yes |
| <a name="input_private_endpoint_configurations"></a> [private\_endpoint\_configurations](#input\_private\_endpoint\_configurations) | Map of private endpoint configurations, specifying the VNet name/resource-group and a new subnet CIDR. A subnet, private endpoint and DNS zone will be created within the specified VNet.<br>  {<br>    endpoint-name = {<br>      vnet\_name: The Name of the VNet to create the private endpoint resources<br>      vnet\_resource\_group\_name: The Name of the resource group containing the VNet<br>      subnet\_cidr: THe CIDR of the Private Endpoint subnet to be created<br>      route\_table\_name: The Route Table ID to associate the subnet with (Optional)<br>    }<br>  } | <pre>map(object({<br>    vnet_name                       = string<br>    vnet_resource_group_name        = string<br>    subnet_cidr                     = string<br>    subnet_route_table_name         = optional(string, null)<br>    create_acr_privatelink_dns_zone = optional(bool, true)<br>  }))</pre> | `{}` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name. Will be used along with `environment` as a prefix for all resources. | `string` | n/a | yes |
| <a name="input_registry_admin_enabled"></a> [registry\_admin\_enabled](#input\_registry\_admin\_enabled) | Specifies whether the admin user is enabled | `bool` | `false` | no |
| <a name="input_registry_network_allowed_ip_ranges"></a> [registry\_network\_allowed\_ip\_ranges](#input\_registry\_network\_allowed\_ip\_ranges) | Allowed IP ranges for the registry | `list(string)` | `[]` | no |
| <a name="input_registry_public_access_enabled"></a> [registry\_public\_access\_enabled](#input\_registry\_public\_access\_enabled) | Whether public network access is allowed for the container registry | `bool` | `false` | no |
| <a name="input_registry_retention_days"></a> [registry\_retention\_days](#input\_registry\_retention\_days) | (preview) The number of days to retain an untagged manifest after which it gets purged. | `number` | `7` | no |
| <a name="input_registry_sku"></a> [registry\_sku](#input\_registry\_sku) | The registry SKU. To create Private Endpoints, 'Premium' is required. | `string` | `"Basic"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be applied to all resources | `map(string)` | `{}` | no |
| <a name="input_tfvars_filename"></a> [tfvars\_filename](#input\_tfvars\_filename) | tfvars filename. This file is uploaded and stored encrypted within Key Vault, to ensure that the latest tfvars are stored in a shared place. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
