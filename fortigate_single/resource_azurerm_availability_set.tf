resource "azurerm_availability_set" "availability_set" {
  for_each = local.availability_set ? local.availability_sets : {}

  resource_group_name = each.value.resource_group_name
  location            = each.value.location

  name = each.value.name

  platform_update_domain_count = each.value.platform_update_domain_count
  platform_fault_domain_count  = each.value.platform_fault_domain_count
  proximity_placement_group_id = each.value.proximity_placement_group_id
  managed                      = each.value.managed
}

output "availability_sets" {
  value = var.enable_output ? azurerm_availability_set.availability_set[*] : null
}
