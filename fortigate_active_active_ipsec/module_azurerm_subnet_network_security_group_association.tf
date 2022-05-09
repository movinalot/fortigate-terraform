module "module_azurerm_subnet_network_security_group_association" {
  for_each = local.subnet_network_security_group_associations

  source = "../azure/rm/azurerm_subnet_network_security_group_association"

  subnet_id                 = each.value.subnet_id
  network_security_group_id = each.value.network_security_group_id
}

output "subnet_network_security_group_associations" {
  value = var.enable_module_output ? module.module_azurerm_subnet_network_security_group_association[*] : null
}
