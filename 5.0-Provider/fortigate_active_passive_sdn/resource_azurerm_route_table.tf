resource "azurerm_route_table" "route_table" {
  for_each = local.route_tables

  resource_group_name = each.value.resource_group_name
  location            = each.value.location

  name = each.value.name
}

output "route_tables" {
  value = var.enable_output ? azurerm_route_table.route_table[*] : null
}
