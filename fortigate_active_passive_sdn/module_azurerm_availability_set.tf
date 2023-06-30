module "module_azurerm_availability_set" {
  for_each = local.availability_sets

  source = "../azure/rm/azurerm_availability_set"

  resource_group_name = each.value.resource_group_name
  location            = each.value.location

  name = each.value.name


  platform_update_domain_count = each.value.platform_update_domain_count
  platform_fault_domain_count  = each.value.platform_fault_domain_count
  proximity_placement_group_id = each.value.proximity_placement_group_id
  managed                      = each.value.managed

}

output "availability_sets" {
  value = var.enable_module_output ? module.module_azurerm_availability_set[*] : null
}
