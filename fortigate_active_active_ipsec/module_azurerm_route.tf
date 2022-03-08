locals {
  routes = {
    "r-default" = {
      name                   = "r-default"
      address_prefix         = "0.0.0.0/0"
      next_hop_in_ip_address = module.module_azurerm_lb["internal_lb"].lb.private_ip_address
      next_hop_type          = "VirtualAppliance"
      route_table_name       = module.module_azurerm_route_table["rt-protected"].route_table.name
    }
  }
}

module "module_azurerm_route" {
  for_each = local.routes

  source = "../azure/rm/azurerm_route"

  resource_group_name    = module.module_azurerm_resource_group.resource_group.name
  name                   = each.value.name
  address_prefix         = each.value.address_prefix
  next_hop_in_ip_address = each.value.next_hop_in_ip_address
  next_hop_type          = each.value.next_hop_type
  route_table_name       = each.value.route_table_name
}

output "routes" {
  value = module.module_azurerm_route[*]
}
