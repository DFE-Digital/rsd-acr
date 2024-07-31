resource "azurerm_container_registry_agent_pool" "acr" {
  count = local.enable_agent_pool ? 1 : 0

  name                      = "${replace(local.resource_prefix, "-", "")}pool"
  resource_group_name       = azurerm_resource_group.acr.name
  location                  = azurerm_resource_group.acr.location
  container_registry_name   = azurerm_container_registry.acr.name
  tier                      = local.agent_pool_sku
  virtual_network_subnet_id = azurerm_subnet.agent_pool[0].id
  tags                      = local.tags
}
