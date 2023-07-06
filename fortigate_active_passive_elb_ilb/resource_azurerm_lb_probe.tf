resource "azurerm_lb_probe" "lb_probe" {

  for_each = local.lb_probes

  name                = each.value.name
  loadbalancer_id     = each.value.loadbalancer_id
  port                = each.value.port
  interval_in_seconds = each.value.interval_in_seconds
}

output "lb_probes" {
  value = var.enable_output ? azurerm_lb_probe.lb_probe[*] : null
}
