locals {
  environment     = var.environment
  project_name    = var.project_name
  azure_location  = var.azure_location
  resource_prefix = "${local.environment}${local.project_name}"
  tags            = var.tags

  key_vault_access_ipv4 = var.key_vault_access_ipv4
  tfvars_filename       = var.tfvars_filename

  registry_sku                       = var.registry_sku
  registry_admin_enabled             = var.registry_admin_enabled
  registry_public_access_enabled     = length(local.registry_network_allowed_ip_ranges) > 0 ? true : var.registry_public_access_enabled
  registry_network_allowed_ip_ranges = var.registry_network_allowed_ip_ranges
  registry_retention_days            = var.registry_retention_days
  enable_weekly_purge_task           = var.enable_weekly_purge_task

  assign_acrpull_role_to_uami = var.assign_acrpull_role_to_uami
  assign_acrpush_role_to_uami = var.assign_acrpush_role_to_uami

  private_endpoint_configurations = var.private_endpoint_configurations
}
