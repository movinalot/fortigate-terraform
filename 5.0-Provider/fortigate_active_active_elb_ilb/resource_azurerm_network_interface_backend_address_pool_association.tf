resource "azurerm_network_interface_backend_address_pool_association" "network_interface_backend_address_pool_association" {
  for_each = local.network_interface_backend_address_pool_associations

  network_interface_id    = each.value.network_interface_id
  ip_configuration_name   = each.value.ip_configuration_name
  backend_address_pool_id = each.value.backend_address_pool_id
}

output "network_interface_backend_address_pool_association" {
  value = var.enable_output ? azurerm_network_interface_backend_address_pool_association.network_interface_backend_address_pool_association[*] : null
}
