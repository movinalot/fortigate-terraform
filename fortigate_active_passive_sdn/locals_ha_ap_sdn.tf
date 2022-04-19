locals {
  resource_groups = {
    (var.resource_group_name) = {
      name     = var.resource_group_name
      location = var.resource_group_location
    }
  }

  public_ips = {
    "pip_fgt" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      location            = module.module_azurerm_resource_group[var.resource_group_name].resource_group.location

      name              = "pip_fgt"
      allocation_method = "Static"
      sku               = "Standard"
    }
    "pip_fgt_a_mgmt" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      location            = module.module_azurerm_resource_group[var.resource_group_name].resource_group.location

      name              = "pip_fgt_a_mgmt"
      allocation_method = "Static"
      sku               = "Standard"
    }
    "pip_fgt_b_mgmt" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      location            = module.module_azurerm_resource_group[var.resource_group_name].resource_group.location

      name              = "pip_fgt_b_mgmt"
      allocation_method = "Static"
      sku               = "Standard"
    }
  }

  virtual_networks = {
    (var.virtual_network_name) = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      location            = module.module_azurerm_resource_group[var.resource_group_name].resource_group.location

      name          = var.virtual_network_name
      address_space = var.virtual_network_address_space
    }
  }

  subnets = {
    "external" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name

      name             = "external"
      vnet_name        = var.virtual_network_name
      address_prefixes = [cidrsubnet(module.module_azurerm_virtual_network[var.virtual_network_name].virtual_network.address_space[0], 4, 0)]
    }
    "internal" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name

      name             = "internal"
      vnet_name        = var.virtual_network_name
      address_prefixes = [cidrsubnet(module.module_azurerm_virtual_network[var.virtual_network_name].virtual_network.address_space[0], 4, 1)]
    }
    "hasync" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name

      name             = "hasync"
      vnet_name        = var.virtual_network_name
      address_prefixes = [cidrsubnet(module.module_azurerm_virtual_network[var.virtual_network_name].virtual_network.address_space[0], 4, 2)]
    }
    "mgmt" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name

      name             = "mgmt"
      vnet_name        = var.virtual_network_name
      address_prefixes = [cidrsubnet(module.module_azurerm_virtual_network[var.virtual_network_name].virtual_network.address_space[0], 4, 3)]
    }
    "protected" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name

      name             = "protected"
      vnet_name        = var.virtual_network_name
      address_prefixes = [cidrsubnet(module.module_azurerm_virtual_network[var.virtual_network_name].virtual_network.address_space[0], 2, 0)]
    }
  }

  network_interfaces = {
    "nic_fortigate_1_1" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      location            = module.module_azurerm_resource_group[var.resource_group_name].resource_group.location

      name                          = "nic_fortigate_1_1"
      enable_ip_forwarding          = true
      enable_accelerated_networking = true
      ip_configurations = [
        {
          name                          = "ipconfig1"
          subnet_id                     = module.module_azurerm_subnet["external"].subnet.id
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(module.module_azurerm_subnet["external"].subnet.address_prefixes[0], 4)
          public_ip_address_id          = module.module_azurerm_public_ip["pip_fgt"].public_ip.id
        }
      ]
    }
    "nic_fortigate_1_2" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      location            = module.module_azurerm_resource_group[var.resource_group_name].resource_group.location

      name                          = "nic_fortigate_1_2"
      enable_ip_forwarding          = true
      enable_accelerated_networking = true
      ip_configurations = [
        {
          name                          = "ipconfig1"
          subnet_id                     = module.module_azurerm_subnet["internal"].subnet.id
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(module.module_azurerm_subnet["internal"].subnet.address_prefixes[0], 4)
          public_ip_address_id          = null
        }
      ]
    }
    "nic_fortigate_1_3" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      location            = module.module_azurerm_resource_group[var.resource_group_name].resource_group.location

      name                          = "nic_fortigate_1_3"
      enable_ip_forwarding          = true
      enable_accelerated_networking = true
      ip_configurations = [
        {
          name                          = "ipconfig1"
          subnet_id                     = module.module_azurerm_subnet["hasync"].subnet.id
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(module.module_azurerm_subnet["hasync"].subnet.address_prefixes[0], 4)
          public_ip_address_id          = null
        }
      ]
    }
    "nic_fortigate_1_4" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      location            = module.module_azurerm_resource_group[var.resource_group_name].resource_group.location

      name                          = "nic_fortigate_1_4"
      enable_ip_forwarding          = true
      enable_accelerated_networking = true
      ip_configurations = [
        {
          name                          = "ipconfig1"
          subnet_id                     = module.module_azurerm_subnet["mgmt"].subnet.id
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(module.module_azurerm_subnet["mgmt"].subnet.address_prefixes[0], 4)
          public_ip_address_id          = null
        }
      ]
    }
    "nic_fortigate_2_1" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      location            = module.module_azurerm_resource_group[var.resource_group_name].resource_group.location

      name                          = "nic_fortigate_2_1"
      enable_ip_forwarding          = true
      enable_accelerated_networking = true
      ip_configurations = [
        {
          name                          = "ipconfig1"
          subnet_id                     = module.module_azurerm_subnet["external"].subnet.id
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(module.module_azurerm_subnet["external"].subnet.address_prefixes[0], 5)
          public_ip_address_id          = null
        }
      ]
    }
    "nic_fortigate_2_2" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      location            = module.module_azurerm_resource_group[var.resource_group_name].resource_group.location

      name                          = "nic_fortigate_2_2"
      enable_ip_forwarding          = true
      enable_accelerated_networking = true
      ip_configurations = [
        {
          name                          = "ipconfig1"
          subnet_id                     = module.module_azurerm_subnet["internal"].subnet.id
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(module.module_azurerm_subnet["internal"].subnet.address_prefixes[0], 5)
          public_ip_address_id          = null
        }
      ]
    }
    "nic_fortigate_2_3" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      location            = module.module_azurerm_resource_group[var.resource_group_name].resource_group.location

      name                          = "nic_fortigate_2_3"
      enable_ip_forwarding          = true
      enable_accelerated_networking = true
      ip_configurations = [
        {
          name                          = "ipconfig1"
          subnet_id                     = module.module_azurerm_subnet["hasync"].subnet.id
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(module.module_azurerm_subnet["hasync"].subnet.address_prefixes[0], 5)
          public_ip_address_id          = null
        }
      ]
    }
    "nic_fortigate_2_4" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      location            = module.module_azurerm_resource_group[var.resource_group_name].resource_group.location

      name                          = "nic_fortigate_2_4"
      enable_ip_forwarding          = true
      enable_accelerated_networking = true
      ip_configurations = [
        {
          name                          = "ipconfig1"
          subnet_id                     = module.module_azurerm_subnet["mgmt"].subnet.id
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(module.module_azurerm_subnet["mgmt"].subnet.address_prefixes[0], 5)
          public_ip_address_id          = null
        }
      ]
    }
  }

  route_tables = {
    "rt_protected" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      location            = module.module_azurerm_resource_group[var.resource_group_name].resource_group.location

      name = "rt_protected"
    }
  }

  routes = {
    "r_default" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name

      name                   = "r_default"
      address_prefix         = "0.0.0.0/0"
      next_hop_in_ip_address = module.module_azurerm_network_interface["nic_fortigate_1_2"].network_interface.private_ip_address
      next_hop_type          = "VirtualAppliance"
      route_table_name       = module.module_azurerm_route_table["rt_protected"].route_table.name
    }
  }
}