module "azurerm_key_vault" {
  source = "github.com/DFE-Digital/terraform-azurerm-key-vault-tfvars?ref=v0.5.1"

  environment                             = local.environment
  project_name                            = local.project_name
  existing_resource_group                 = azurerm_resource_group.acr.name
  azure_location                          = local.azure_location
  key_vault_access_use_rbac_authorization = true
  key_vault_access_users                  = []
  key_vault_access_ipv4                   = local.key_vault_access_ipv4
  tfvars_filename                         = local.tfvars_filename
  enable_diagnostic_setting               = true
  enable_log_analytics_workspace          = true
  enable_diagnostic_storage_account       = false
  tags                                    = local.tags
}
