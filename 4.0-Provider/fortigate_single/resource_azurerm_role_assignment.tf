resource "azurerm_role_assignment" "role_assignment" {
  for_each = local.role_assignments

  scope                = each.value.scope
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id
}

output "role_assignments" {
  value = var.enable_output ? azurerm_role_assignment.role_assignment[*] : null
}
