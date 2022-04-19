module "module_azurerm_route" {
  for_each = local.routes

  source = "../azure/rm/azurerm_route"

  resource_group_name = each.value.resource_group_name

  name                   = each.value.name
  address_prefix         = each.value.address_prefix
  next_hop_in_ip_address = each.value.next_hop_in_ip_address
  next_hop_type          = each.value.next_hop_type
  route_table_name       = each.value.route_table_name
}

output "routes" {
  value = var.enable_module_output ? module.module_azurerm_route[*] : null
}
