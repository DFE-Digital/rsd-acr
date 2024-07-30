resource "azurerm_user_assigned_identity" "acr" {
  name                = "${local.resource_prefix}-uami-acr"
  location            = local.azure_location
  resource_group_name = azurerm_resource_group.acr.name
  tags                = local.tags
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.acr.id
  description          = "Allow the UAMI to pull images from an Azure Container Registry"
}

resource "azurerm_role_assignment" "acr_push" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPush"
  principal_id         = azurerm_user_assigned_identity.acr.id
  description          = "Allow the UAMI to push images to an Azure Container Registry"
}
