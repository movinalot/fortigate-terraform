module "module_azurerm_network_security_rule" {
  for_each = local.network_security_rules

  source = "../azure/rm/azurerm_network_security_rule"

  resource_group_name = each.value.resource_group_name

  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
  network_security_group_name = each.value.network_security_group_name
}

output "network_security_rules" {
  value = var.enable_module_output ? module.module_azurerm_network_security_rule[*] : null
}
