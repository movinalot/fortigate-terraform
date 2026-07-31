resource "azurerm_lb_rule" "lb_rule" {
  for_each = local.lb_rules

  name                           = each.value.name
  loadbalancer_id                = each.value.loadbalancer_id
  frontend_ip_configuration_name = each.value.frontend_ip_configuration_name
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  backend_address_pool_ids       = each.value.backend_address_pool_ids
  probe_id                       = each.value.probe_id
  disable_outbound_snat          = each.value.disable_outbound_snat
}

output "lb_rules" {
  value = var.enable_output ? azurerm_lb_rule.lb_rule[*] : null
}
