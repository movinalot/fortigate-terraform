locals {
  network_interfaces = {
    "nic-fortigate_a_1" = {
      name                          = "nic-fortigate_a_1"
      enable_ip_forwarding          = true
      enable_accelerated_networking = true

      ip_configurations = [
        {
          name                          = "ipconfig1"
          subnet_id                     = module.module_azurerm_subnet["external"].subnet.id
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(module.module_azurerm_subnet["external"].subnet.address_prefix, 5)
          public_ip_address_id          = null
        }
      ]
    }
    "nic-fortigate_a_2" = {
      name                          = "nic-fortigate_a_2"
      enable_ip_forwarding          = true
      enable_accelerated_networking = true

      ip_configurations = [
        {
          name                          = "ipconfig1"
          subnet_id                     = module.module_azurerm_subnet["internal"].subnet.id
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(module.module_azurerm_subnet["internal"].subnet.address_prefix, 5)
          public_ip_address_id          = null
        }
      ]
    }
    "nic-fortigate_a_3" = {
      name                          = "nic-fortigate_a_3"
      enable_ip_forwarding          = true
      enable_accelerated_networking = true

      ip_configurations = [
        {
          name                          = "ipconfig1"
          subnet_id                     = module.module_azurerm_subnet["hasync"].subnet.id
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(module.module_azurerm_subnet["hasync"].subnet.address_prefix, 5)
          public_ip_address_id          = null
        }
      ]
    }
    "nic-fortigate_a_4" = {
      name                          = "nic-fortigate_a_4"
      enable_ip_forwarding          = true
      enable_accelerated_networking = true

      ip_configurations = [
        {
          name                          = "ipconfig1"
          subnet_id                     = module.module_azurerm_subnet["mgmt"].subnet.id
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(module.module_azurerm_subnet["mgmt"].subnet.address_prefix, 5)
          public_ip_address_id          = module.module_azurerm_public_ip["pip-fgt-a-mgmt"].public_ip.id
        }
      ]
    }
    "nic-fortigate_b_1" = {
      name                          = "nic-fortigate_b_1"
      enable_ip_forwarding          = true
      enable_accelerated_networking = true
      ip_configuration_name         = "ipconfig1"

      ip_configurations = [
        {
          name                          = "ipconfig1"
          subnet_id                     = module.module_azurerm_subnet["external"].subnet.id
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(module.module_azurerm_subnet["external"].subnet.address_prefix, 6)
          public_ip_address_id          = null
        }
      ]
    }
    "nic-fortigate_b_2" = {
      name                          = "nic-fortigate_b_2"
      enable_ip_forwarding          = true
      enable_accelerated_networking = true

      ip_configurations = [
        {
          name                          = "ipconfig1"
          subnet_id                     = module.module_azurerm_subnet["internal"].subnet.id
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(module.module_azurerm_subnet["internal"].subnet.address_prefix, 6)
          public_ip_address_id          = null
        }
      ]
    }
    "nic-fortigate_b_3" = {
      name                          = "nic-fortigate_b_3"
      enable_ip_forwarding          = true
      enable_accelerated_networking = true
      ip_configuration_name         = "ipconfig1"

      ip_configurations = [
        {
          name                          = "ipconfig1"
          subnet_id                     = module.module_azurerm_subnet["hasync"].subnet.id
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(module.module_azurerm_subnet["hasync"].subnet.address_prefix, 6)
          public_ip_address_id          = null
        }
      ]
    }
    "nic-fortigate_b_4" = {
      name                          = "nic-fortigate_b_4"
      enable_ip_forwarding          = true
      enable_accelerated_networking = true
      ip_configuration_name         = "ipconfig1"

      ip_configurations = [
        {
          name                          = "ipconfig1"
          subnet_id                     = module.module_azurerm_subnet["mgmt"].subnet.id
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(module.module_azurerm_subnet["mgmt"].subnet.address_prefix, 6)
          public_ip_address_id          = module.module_azurerm_public_ip["pip-fgt-b-mgmt"].public_ip.id
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
