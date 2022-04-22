module "module_azurerm_subnet_route_table_association" {
  for_each = local.subnet_route_table_associations

  source = "../azure/rm/azurerm_subnet_route_table_association"

  subnet_id      = each.value.subnet_id
  route_table_id = each.value.route_table_id
}

output "subnet_route_table_associations" {
  value = var.enable_module_output ? module.module_azurerm_subnet_route_table_association[*] : null
}
