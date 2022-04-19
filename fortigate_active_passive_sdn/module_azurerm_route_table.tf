module "module_azurerm_route_table" {
  for_each = local.route_tables

  source = "../azure/rm/azurerm_route_table"

  resource_group_name = each.value.resource_group_name
  location            = each.value.location

  name = each.value.name
}

output "route_tables" {
  value = var.enable_module_output ? module.module_azurerm_route_table[*] : null
}
