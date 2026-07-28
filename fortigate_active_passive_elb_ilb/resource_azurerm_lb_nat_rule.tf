resource "azurerm_lb_nat_rule" "lb_nat_rule" {
  for_each = local.lb_nat_rules

  resource_group_name = each.value.resource_group_name

  name                           = each.value.name
  loadbalancer_id                = each.value.loadbalancer_id
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = each.value.frontend_ip_configuration_name
}

output "lb_nat_rules" {
  value = var.enable_output ? azurerm_lb_nat_rule.lb_nat_rule[*] : null
}
