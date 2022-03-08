locals {
  availability_sets = {
    "as_1" = { name = "as_1", platform_update_domain_count = "2", platform_fault_domain_count = "2", proximity_placement_group_id = null, managed = true }
  }
}

module "module_azurerm_availability_set" {
  for_each = local.availability_sets

  source = "../azure/rm/azurerm_availability_set"

  resource_group_name = module.module_azurerm_resource_group.resource_group.name
  location            = module.module_azurerm_resource_group.resource_group.location

  name = each.value.name

  platform_update_domain_count = each.value.platform_update_domain_count
  platform_fault_domain_count  = each.value.platform_fault_domain_count
  proximity_placement_group_id = each.value.proximity_placement_group_id
  managed                      = each.value.managed

}

output "availability_sets" {
  value = module.module_azurerm_availability_set[*]
}
