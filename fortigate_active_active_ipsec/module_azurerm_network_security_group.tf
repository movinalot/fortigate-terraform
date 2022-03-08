locals {
  network_security_groups = {
    "nsg-public"  = { name = "nsg-public" }
    "nsg-private" = { name = "nsg-private" }
  }
}

module "module_azurerm_network_security_group" {
  for_each = local.network_security_groups

  source = "../azure/rm/azurerm_network_security_group"

  resource_group_name = module.module_azurerm_resource_group.resource_group.name
  location            = module.module_azurerm_resource_group.resource_group.location
  name                = each.value.name
}

output "network_security_groups" {
  value = module.module_azurerm_network_security_group[*]
}
