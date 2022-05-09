locals {
  resource_groups = {
    (var.resource_group_name) = {
      name     = var.resource_group_name
      location = var.resource_group_location
    }
  }

  availability_sets = {
    "as_1" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      location            = module.module_azurerm_resource_group[var.resource_group_name].resource_group.location

      name = "as_1"
      platform_update_domain_count = "2"
      platform_fault_domain_count = "2"
      proximity_placement_group_id = null
      managed = true
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
    "pip_fgt_1_ipsec" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      location            = module.module_azurerm_resource_group[var.resource_group_name].resource_group.location

      name              = "pip_fgt_1_ipsec"
      allocation_method = "Static"
      sku               = "Standard"
    }
    "pip_fgt_2_ipsec" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      location            = module.module_azurerm_resource_group[var.resource_group_name].resource_group.location

      name              = "pip_fgt_2_ipsec"
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
      address_prefixes = [cidrsubnet(module.module_azurerm_virtual_network[var.virtual_network_name].virtual_network.address_space[0], 8, 0)]
    }
    "internal" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name

      name             = "internal"
      vnet_name        = var.virtual_network_name
      address_prefixes = [cidrsubnet(module.module_azurerm_virtual_network[var.virtual_network_name].virtual_network.address_space[0], 8, 1)]
    }
    "protected" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name

      name             = "protected"
      vnet_name        = var.virtual_network_name
      address_prefixes = [cidrsubnet(module.module_azurerm_virtual_network[var.virtual_network_name].virtual_network.address_space[0], 8, 2)]
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
          private_ip_address            = cidrhost(module.module_azurerm_subnet["external"].subnet.address_prefix, 5)
          public_ip_address_id          = module.module_azurerm_public_ip["pip_fgt_1_ipsec"].public_ip.id
        }
      ]
    }
    "nic_fortigate_1_2" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      location            = module.module_azurerm_resource_group[var.resource_group_name].resource_group.location

      name                          = "nic-fortigate_1_2"
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
    "nic_fortigate_2_1" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      location            = module.module_azurerm_resource_group[var.resource_group_name].resource_group.location

      name                          = "nic_fortigate_2_1"
      enable_ip_forwarding          = true
      enable_accelerated_networking = true
      ip_configuration_name         = "ipconfig1"

      ip_configurations = [
        {
          name                          = "ipconfig1"
          subnet_id                     = module.module_azurerm_subnet["external"].subnet.id
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(module.module_azurerm_subnet["external"].subnet.address_prefix, 6)
          public_ip_address_id          = module.module_azurerm_public_ip["pip_fgt_2_ipsec"].public_ip.id
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
          private_ip_address            = cidrhost(module.module_azurerm_subnet["internal"].subnet.address_prefix, 6)
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
      next_hop_in_ip_address = module.module_azurerm_lb["lb_internal"].lb.frontend_ip_configuration[0].private_ip_address
      next_hop_type          = "VirtualAppliance"
      route_table_name       = module.module_azurerm_route_table["rt_protected"].route_table.name
    }
  }

  subnet_route_table_associations = {
    "protected" = {
      subnet_id      = module.module_azurerm_subnet["protected"].subnet.id
      route_table_id = module.module_azurerm_route_table["rt_protected"].route_table.id
    }
  }

  network_security_groups = {
    "nsg_external" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      location            = module.module_azurerm_resource_group[var.resource_group_name].resource_group.location

      name = "nsg_external"
    }
    "nsg_internal" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      location            = module.module_azurerm_resource_group[var.resource_group_name].resource_group.location

      name = "nsg_internal"
    }
  }

  network_security_rules = {
    "nsr_external_ingress" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name

      name                        = "nsr_external_ingress"
      priority                    = 1001
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
      network_security_group_name = module.module_azurerm_network_security_group["nsg_external"].network_security_group.name
    },
    "nsr_external_egress" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name

      name                        = "nsr_external_egress"
      priority                    = 1002
      direction                   = "Outbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
      network_security_group_name = module.module_azurerm_network_security_group["nsg_external"].network_security_group.name
    },
    "nsr_internal_ingress" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name

      name                        = "nsr_internal_ingress"
      priority                    = 1003
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
      network_security_group_name = module.module_azurerm_network_security_group["nsg_internal"].network_security_group.name
    },
    "nsr_internal_egress" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name

      name                        = "nsr_internal_egress"
      priority                    = 1004
      direction                   = "Outbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
      network_security_group_name = module.module_azurerm_network_security_group["nsg_internal"].network_security_group.name
    }
  }

  subnet_network_security_group_associations = {
    "external" = {
      subnet_id                 = module.module_azurerm_subnet["external"].subnet.id
      network_security_group_id = module.module_azurerm_network_security_group["nsg_external"].network_security_group.id
    }
    "internal" = {
      subnet_id                 = module.module_azurerm_subnet["internal"].subnet.id
      network_security_group_id = module.module_azurerm_network_security_group["nsg_internal"].network_security_group.id
    }
    "protected" = {
      subnet_id                 = module.module_azurerm_subnet["protected"].subnet.id
      network_security_group_id = module.module_azurerm_network_security_group["nsg_internal"].network_security_group.id
    }
  }

  random_ids = {
    "storage_account_random_id" = {
      keepers_resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      byte_length                 = 8
    }
  }

  storage_accounts = {
    "sa" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      location            = module.module_azurerm_resource_group[var.resource_group_name].resource_group.location

      name                     = format("sa%s", "${random_id.id["storage_account_random_id"].hex}")
      account_replication_type = "LRS"
      account_tier             = "Standard"
    }
  }
  lbs = {
    "lb_external" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      location            = module.module_azurerm_resource_group[var.resource_group_name].resource_group.location

      name                = "lb_external"
      sku                 = "standard"
      frontend_ip_configurations = [
        {
          name                 = "lb_external_fe_ip"
          public_ip_address_id = module.module_azurerm_public_ip["pip_fgt"].public_ip.id
        }
      ]
    }
    
    "lb_internal" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      location            = module.module_azurerm_resource_group[var.resource_group_name].resource_group.location

      name                = "lb_internal"
      sku                 = "standard"
      frontend_ip_configurations = [
        {
          name                          = "lb_internal_fe_ip"
          subnet_id                     = module.module_azurerm_subnet["internal"].subnet.id
          vnet_name                     = module.module_azurerm_virtual_network["vnet_security"].virtual_network.name
          private_ip_address            = cidrhost(module.module_azurerm_subnet["internal"].subnet.address_prefix, 4)
          private_ip_address_allocation = "Static"
          private_ip_address_version    = "IPv4"
        }
      ]
    }
  }

  vm_image = {
    "fortinet" = {
      publisher = "fortinet"
      offer     = "fortinet_fortigate-vm_v5"
      sku       = var.fortigate_sku
      version   = var.fortigate_ver
      vm_size   = var.fortigate_size
    }
  }

  virtual_machines = {
    "vm_fgt_1" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      location            = module.module_azurerm_resource_group[var.resource_group_name].resource_group.location

      name              = "vm-fgt-1"
      identity_identity = "SystemAssigned"

      #availability_set_id or zones can be set but not both. Both can be null
      availability_set_id = module.module_azurerm_availability_set["as_1"].availability_set.id
      zones               = null

      delete_os_disk_on_termination    = true
      delete_data_disks_on_termination = true

      network_interface_ids        = [for nic in ["nic_fortigate_1_1", "nic_fortigate_1_2"] : module.module_azurerm_network_interface[nic].network_interface.id]
      primary_network_interface_id = module.module_azurerm_network_interface["nic_fortigate_1_1"].network_interface.id

      vm_size = "Standard_F4s"

      vm_size = local.vm_image["fortinet"].vm_size

      storage_image_reference_publisher = local.vm_image["fortinet"].publisher
      storage_image_reference_offer     = local.vm_image["fortinet"].offer
      storage_image_reference_sku       = local.vm_image["fortinet"].sku
      storage_image_reference_version   = local.vm_image["fortinet"].version

      plan_publisher = local.vm_image["fortinet"].publisher
      plan_product   = local.vm_image["fortinet"].offer
      plan_name      = local.vm_image["fortinet"].sku

      os_profile_admin_username = "azureuser"
      os_profile_admin_password = "Password123!!"

      os_profile_linux_config_disable_password_authentication = false

      boot_diagnostics_enabled                                = true
      boot_diagnostics_storage_uri                            = module.module_azurerm_storage_account["sa"].storage_account.primary_blob_endpoint

      storage_os_disk_name              = "disk_os_fgt_1"
      storage_os_disk_caching           = "ReadWrite"
      storage_os_disk_managed_disk_type = "Premium_LRS"
      storage_os_disk_create_option     = "FromImage"

      storage_data_disks = [
        {
          name              = "disk_data_fgt_1"
          managed_disk_type = "Premium_LRS"
          create_option     = "Empty"
          disk_size_gb      = "30"
          lun               = "0"
        }
      ]
      # FortiGate Configuration
      config_data = null
    }

    "vm_fgt_2" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      location            = module.module_azurerm_resource_group[var.resource_group_name].resource_group.location

      name              = "vm-fgt-2"
      identity_identity = "SystemAssigned"

      #availability_set_id or zones can be set but not both. Both can be null
      availability_set_id = module.module_azurerm_availability_set["as_1"].availability_set.id
      zones               = null

      delete_os_disk_on_termination    = true
      delete_data_disks_on_termination = true

      network_interface_ids        = [for nic in ["nic_fortigate_2_1", "nic_fortigate_2_2"] : module.module_azurerm_network_interface[nic].network_interface.id]
      primary_network_interface_id = module.module_azurerm_network_interface["nic_fortigate_2_1"].network_interface.id

      vm_size = local.vm_image["fortinet"].vm_size

      storage_image_reference_publisher = local.vm_image["fortinet"].publisher
      storage_image_reference_offer     = local.vm_image["fortinet"].offer
      storage_image_reference_sku       = local.vm_image["fortinet"].sku
      storage_image_reference_version   = local.vm_image["fortinet"].version

      plan_publisher = local.vm_image["fortinet"].publisher
      plan_product   = local.vm_image["fortinet"].offer
      plan_name      = local.vm_image["fortinet"].sku

      os_profile_admin_username = "azureuser"
      os_profile_admin_password = "Password123!!"

      os_profile_linux_config_disable_password_authentication = false

      boot_diagnostics_enabled                                = true
      boot_diagnostics_storage_uri                            = module.module_azurerm_storage_account["sa"].storage_account.primary_blob_endpoint

      storage_os_disk_name              = "disk_os_fgt_2"
      storage_os_disk_caching           = "ReadWrite"
      storage_os_disk_managed_disk_type = "Premium_LRS"
      storage_os_disk_create_option     = "FromImage"

      storage_data_disks = [
        {
          name              = "disk_data_fgt_2"
          managed_disk_type = "Premium_LRS"
          create_option     = "Empty"
          disk_size_gb      = "30"
          lun               = "0"
        }
      ]
      # FortiGate Configuration
      config_data = null
    }
  }

  role_assignments = {
    "vm_fgt_1" = {
      scope                = module.module_azurerm_resource_group[var.resource_group_name].resource_group.id
      role_definition_name = "Contributor"
      principal_id         = module.module_azurerm_virtual_machine["vm_fgt_1"].virtual_machine.identity[0].principal_id
    }
    "vm_fgt_2" = {
      scope                = module.module_azurerm_resource_group[var.resource_group_name].resource_group.id
      role_definition_name = "Contributor"
      principal_id         = module.module_azurerm_virtual_machine["vm_fgt_2"].virtual_machine.identity[0].principal_id
    }
  }
}