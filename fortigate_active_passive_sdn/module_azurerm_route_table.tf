locals {
  route_tables = {
    (var.route_tables["route_table_01"].name) = {
      name = var.route_tables["route_table_01"].name
    }
  }
}

module "module_azurerm_route_table" {
  for_each = local.route_tables

  source = "../azure/rm/azurerm_route_table"

  resource_group_name = module.module_azurerm_resource_group.resource_group.name
  location            = module.module_azurerm_resource_group.resource_group.location
  name                = each.value.name
}

output "route_tables" {
  value = module.module_azurerm_route_table[*]
}
