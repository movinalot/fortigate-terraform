locals {
  network_interfaces = {
    "nic-fortigate_1" = {
      name                          = "nic-fortigate_1"
      enable_ip_forwarding          = true
      enable_accelerated_networking = true
      ip_configurations = [
        {
          name                          = "ipconfig1"
          subnet_id                     = module.module_azurerm_subnet["external"].subnet.id
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(module.module_azurerm_subnet["external"].subnet.address_prefix, 4)
          public_ip_address_id          = module.module_azurerm_public_ip["pip-fgt"].public_ip.id
        }
      ]
    },
    "nic-fortigate_2" = {
      name                          = "nic-fortigate_2"
      enable_ip_forwarding          = true
      enable_accelerated_networking = true
      ip_configurations = [
        {
          name                          = "ipconfig1"
          subnet_id                     = module.module_azurerm_subnet["internal"].subnet.id
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(module.module_azurerm_subnet["internal"].subnet.address_prefix, 4)
          public_ip_address_id          = null
        }
      ]
    }
  }
}

module "module_azurerm_network_interface" {
  for_each = local.network_interfaces

  source = "../azure/rm/azurerm_network_interface"

  resource_group_name           = module.module_azurerm_resource_group.resource_group.name
  location                      = module.module_azurerm_resource_group.resource_group.location
  name                          = each.value.name
  enable_ip_forwarding          = each.value.enable_ip_forwarding
  enable_accelerated_networking = each.value.enable_accelerated_networking

  ip_configurations = each.value.ip_configurations
}

output "network_interfaces" {
  value = module.module_azurerm_network_interface[*]
}
