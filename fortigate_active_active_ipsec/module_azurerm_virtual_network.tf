locals {
  virtual_networks = {
    "vnet-fortigate-aa" = {
      name          = "vnet-fortigate-aa"
      address_space = ["10.225.0.0/16"]
    }
  }
}
module "module_azurerm_virtual_network" {
  for_each = local.virtual_networks

  source = "../azure/rm/azurerm_virtual_network"

  resource_group_name = module.module_azurerm_resource_group.resource_group.name
  location            = module.module_azurerm_resource_group.resource_group.location
  name                = each.value.name
  address_space       = each.value.address_space

}

output "virtual_networks" {
  value = module.module_azurerm_virtual_network[*]
}
