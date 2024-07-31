resource "azurerm_virtual_network" "default" {
  count = local.enable_agent_pool ? 1 : 0

  name                = "${local.resource_prefix}default"
  address_space       = ["172.16.0.0/12"]
  resource_group_name = azurerm_resource_group.acr.name
  location            = azurerm_resource_group.acr.location
  tags                = local.tags
}

resource "azurerm_subnet" "agent_pool" {
  count = local.enable_agent_pool ? 1 : 0

  name                 = "${local.resource_prefix}agentpoolinfra"
  virtual_network_name = azurerm_virtual_network.default[0].name
  resource_group_name  = azurerm_resource_group.acr.name
  address_prefixes     = ["172.16.0.0/29"]
}
