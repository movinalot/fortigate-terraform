locals {
  subnet_route_table_associations = {
    "subnet-protected" = {
      subnet_id      = "protected"
      route_table_id = "rt-protected"
    }
  }
}

module "module_azurerm_subnet_route_table_association" {
  for_each = local.subnet_route_table_associations

  source = "../azure/rm/azurerm_subnet_route_table_association"

  subnet_id      = module.module_azurerm_subnet[each.value.subnet_id].subnet.id
  route_table_id = module.module_azurerm_route_table[each.value.route_table_id].route_table.id
}

output "subnet_route_table_associations" {
  value = module.module_azurerm_subnet_route_table_association[*]
}
