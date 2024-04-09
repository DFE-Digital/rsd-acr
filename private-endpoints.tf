resource "azurerm_subnet" "acr_private_endpoint" {
  for_each = local.private_endpoint_configutations

  name                                      = "${local.resource_prefix}-${each.key}-acrprivateendpoint"
  virtual_network_name                      = data.azurerm_virtual_network.private_endpoints[each.key].name
  resource_group_name                       = data.azurerm_virtual_network.private_endpoints[each.key].resource_group_name
  address_prefixes                          = [each.value["subnet_cidr"]]
  private_endpoint_network_policies_enabled = true
}

resource "azurerm_subnet_route_table_association" "acr_private_endpoint" {
  for_each = {
    for k, v in local.private_endpoint_configutations : k => v if v["subnet_route_table_name"] != null
  }

  subnet_id      = azurerm_subnet.acr_private_endpoint[each.key].id
  route_table_id = data.azurerm_route_table.private_endpoints[each.key].id
}

resource "azurerm_private_endpoint" "acr" {
  for_each = local.private_endpoint_configutations

  name                = "${local.resource_prefix}${each.key}"
  location            = data.azurerm_virtual_network.private_endpoints[each.key].location
  resource_group_name = data.azurerm_virtual_network.private_endpoints[each.key].resource_group_name
  subnet_id           = azurerm_subnet.acr_private_endpoint[each.key].id

  private_service_connection {
    name                           = "${local.resource_prefix}${each.key}connection"
    private_connection_resource_id = azurerm_container_registry.acr.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  tags = local.tags
}

resource "azurerm_private_dns_zone" "acr_private_link" {
  for_each = local.private_endpoint_configutations

  name                = "${azurerm_container_registry.acr.name}.azurecr.io"
  resource_group_name = data.azurerm_virtual_network.private_endpoints[each.key].resource_group_name
  tags                = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "acr_private_link" {
  for_each = local.private_endpoint_configutations

  name                  = "${local.resource_prefix}acrprivatelink"
  resource_group_name   = data.azurerm_virtual_network.private_endpoints[each.key].resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.acr_private_link[each.key].name
  virtual_network_id    = data.azurerm_virtual_network.private_endpoints[each.key].id
  tags                  = local.tags
}

resource "azurerm_private_dns_a_record" "acr_private_endpoint" {
  for_each = local.private_endpoint_configutations

  name                = "@"
  zone_name           = azurerm_private_dns_zone.acr_private_link[each.key].name
  resource_group_name = data.azurerm_virtual_network.private_endpoints[each.key].resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.acr[each.key].private_service_connection[0].private_ip_address]
  tags                = local.tags
}
