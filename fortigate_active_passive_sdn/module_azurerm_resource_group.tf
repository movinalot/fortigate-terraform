module "module_azurerm_resource_group" {
  for_each = local.resource_groups

  source = "../azure/rm/azurerm_resource_group"

  name     = each.value.name
  location = each.value.location
}

resource "azurerm_resource_group" "resource_group" {
  for_each = local.resource_groups

  name     = each.value.name
  location = each.value.location

  tags = {}

  lifecycle {
    ignore_changes = [
      tags["CreatedOnDate"]
    ]
  }
}

output "resource_group" {
  value = var.enable_module_output ? azurerm_resource_group.resource_group[*] : null
}

output "resource_groups" {
  value = var.enable_module_output ? module.module_azurerm_resource_group[*] : null
}
