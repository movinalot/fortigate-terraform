locals {
  subnets = {
    "external"  = { name = "external", vnet_name = "vnet-fortigate", address_prefixes = [cidrsubnet(module.module_azurerm_virtual_network["vnet-fortigate"].virtual_network.address_space[0], 8, 0)] }
    "internal"  = { name = "internal", vnet_name = "vnet-fortigate", address_prefixes = [cidrsubnet(module.module_azurerm_virtual_network["vnet-fortigate"].virtual_network.address_space[0], 8, 1)] }
    "protected" = { name = "protected", vnet_name = "vnet-fortigate", address_prefixes = [cidrsubnet(module.module_azurerm_virtual_network["vnet-fortigate"].virtual_network.address_space[0], 8, 2)] }
  }
}

module "module_azurerm_subnet" {
  for_each = local.subnets

  source = "../azure/rm/azurerm_subnet"

  resource_group_name = module.module_azurerm_resource_group.resource_group.name
  name                = each.value.name
  vnet_name           = each.value.vnet_name
  address_prefixes    = each.value.address_prefixes

  depends_on = [
    module.module_azurerm_virtual_network
  ]
}

output "subnets" {
  value = module.module_azurerm_subnet[*]
}
