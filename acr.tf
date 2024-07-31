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

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.acr.id]
  }
}

resource "azurerm_container_registry_task" "untagged" {
  count = local.enable_weekly_purge_task ? 1 : 0

  name                  = "untag-and-prune-unused-images"
  container_registry_id = azurerm_container_registry.acr.id

  platform {
    os = "Linux"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.acr.id]
  }

  timer_trigger {
    name     = "At 00:00 on Sunday"
    enabled  = true
    schedule = "0 0 * * 0"
  }

  tags = local.tags
}
