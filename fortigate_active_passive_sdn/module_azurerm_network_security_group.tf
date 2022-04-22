module "module_azurerm_network_security_group" {
  for_each = local.network_security_groups

  source = "../azure/rm/azurerm_network_security_group"

  resource_group_name = each.value.resource_group_name
  location            = each.value.location

  name = each.value.name
}

output "network_security_groups" {
  value = var.enable_module_output ? module.module_azurerm_network_security_group[*] : null
}
