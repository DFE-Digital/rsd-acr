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
  retention_policy_in_days      = local.registry_retention_days

  dynamic "network_rule_set" {
    for_each = local.registry_sku == "Premium" ? { ip_rules : local.registry_network_allowed_ip_ranges } : {}

    content {
      default_action = "Deny"

      dynamic "ip_rule" {
        for_each = network_rule_set.value

        content {
          action   = "Allow"
          ip_range = ip_rule.value
        }
      }
    }
  }
}
