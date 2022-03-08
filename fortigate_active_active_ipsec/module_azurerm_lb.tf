locals {
  lbs = {
    "external_lb" = {
      name                = "external_lb"
      sku                 = "standard"
      resource_group_name = module.module_azurerm_resource_group.resource_group.name
      location            = module.module_azurerm_resource_group.resource_group.location
      frontend_ip_configurations = [
        {
          name                 = "external_lb_fe_ip"
          public_ip_address_id = module.module_azurerm_public_ip["pip-fgt-v-lb-fe"].public_ip.id
        }
      ]
    },
    "internal_lb" = {
      name                = "internal_lb"
      sku                 = "standard"
      resource_group_name = module.module_azurerm_resource_group.resource_group.name
      location            = module.module_azurerm_resource_group.resource_group.location
      frontend_ip_configurations = [
        {
          name                          = "internal_lb_fe_ip"
          subnet_id                     = module.module_azurerm_subnet["internal"].subnet.id
          vnet_name                     = module.module_azurerm_virtual_network["vnet-fortigate-aa"].virtual_network.name
          private_ip_address            = cidrhost(module.module_azurerm_subnet["internal"].subnet.address_prefix, 4)
          private_ip_address_allocation = "Static"
          private_ip_address_version    = "IPv4"
        }
      ]
    }
  }
}
module "module_azurerm_lb" {
  for_each = local.lbs

  source = "../azure/rm/azurerm_lb"

  resource_group_name        = var.resource_group_name
  location                   = var.resource_group_location
  name                       = each.value.name
  sku                        = each.value.sku
  frontend_ip_configurations = each.value.frontend_ip_configurations
}

output "lbs" {
  value = module.module_azurerm_lb[*]
}