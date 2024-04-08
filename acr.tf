resource "azurerm_resource_group" "acr" {
  name     = local.resource_prefix
  location = local.azure_location
  tags     = local.tags
}

resource "azurerm_container_registry" "acr" {
  name                          = replace(local.resource_prefix, "-", "")
  resource_group_name           = azurerm_resource_group.acr.name
  location                      = azurerm_resource_group.acr.location
  sku                           = local.registry_sku
  admin_enabled                 = local.registry_admin_enabled
  public_network_access_enabled = local.registry_public_access_enabled
  tags                          = local.tags

  dynamic "retention_policy" {
    for_each = local.registry_sku == "Premium" ? [1] : []

    content {
      days    = local.registry_retention_days
      enabled = local.registry_retention_days > 0
    }
  }

  dynamic "network_rule_set" {
    for_each = local.registry_sku == "Premium" && !local.registry_public_access_enabled ? [1] : []

    content {
      default_action = "Deny"
    }
  }
}
