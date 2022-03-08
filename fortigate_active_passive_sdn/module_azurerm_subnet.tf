locals {
  subnets = {
    (var.subnets["subnet_01"].name) = {
      name = var.subnets["subnet_01"].name
      address_prefixes = [cidrsubnet(
        module.module_azurerm_virtual_network[var.virtual_network_name].virtual_network.address_space[0],
        var.subnets["subnet_01"].cidrsubnet_newbits,
        var.subnets["subnet_01"].cidrsubnet_netnum
      )]
    }
    (var.subnets["subnet_02"].name) = {
      name = var.subnets["subnet_02"].name
      address_prefixes = [cidrsubnet(
        module.module_azurerm_virtual_network[var.virtual_network_name].virtual_network.address_space[0],
        var.subnets["subnet_02"].cidrsubnet_newbits,
        var.subnets["subnet_02"].cidrsubnet_netnum
      )]
    }
    (var.subnets["subnet_03"].name) = {
      name = var.subnets["subnet_03"].name
      address_prefixes = [cidrsubnet(
        module.module_azurerm_virtual_network[var.virtual_network_name].virtual_network.address_space[0],
        var.subnets["subnet_03"].cidrsubnet_newbits,
        var.subnets["subnet_03"].cidrsubnet_netnum
      )]
    }
    (var.subnets["subnet_04"].name) = {
      name = var.subnets["subnet_04"].name
      address_prefixes = [cidrsubnet(
        module.module_azurerm_virtual_network[var.virtual_network_name].virtual_network.address_space[0],
        var.subnets["subnet_04"].cidrsubnet_newbits,
        var.subnets["subnet_04"].cidrsubnet_netnum
      )]
    }
    (var.subnets["subnet_05"].name) = {
      name = var.subnets["subnet_05"].name
      address_prefixes = [cidrsubnet(
        module.module_azurerm_virtual_network[var.virtual_network_name].virtual_network.address_space[0],
        var.subnets["subnet_05"].cidrsubnet_newbits,
        var.subnets["subnet_05"].cidrsubnet_netnum
      )]
    }
  }

  virtual_network_name = var.virtual_network_name
}

module "module_azurerm_subnet" {
  for_each = local.subnets

  source = "../azure/rm/azurerm_subnet"

  resource_group_name = module.module_azurerm_resource_group.resource_group.name
  name                = each.value.name
  vnet_name           = module.module_azurerm_virtual_network[local.virtual_network_name].virtual_network.name
  address_prefixes    = each.value.address_prefixes

}

output "subnets" {
  value = module.module_azurerm_subnet[*]
}
