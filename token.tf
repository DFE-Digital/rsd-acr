resource "azurerm_container_registry_scope_map" "rw-all" {
  name                    = "read-write-all-repositories"
  container_registry_name = azurerm_container_registry.acr.name
  resource_group_name     = azurerm_resource_group.acr.name

  actions = [
    "content/read",
    "content/write"
  ]
}
