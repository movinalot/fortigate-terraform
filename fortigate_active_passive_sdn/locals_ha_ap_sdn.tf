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

  availability_sets = {
    "as_1" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      location            = module.module_azurerm_resource_group[var.resource_group_name].resource_group.location

      name                         = "as_1"
      platform_update_domain_count = "2"
      platform_fault_domain_count  = "2"
      proximity_placement_group_id = null
      managed                      = true
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
      address_prefixes = [cidrsubnet(module.module_azurerm_virtual_network[var.virtual_network_name].virtual_network.address_space[0], 2, 1)]
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
          public_ip_address_id          = module.module_azurerm_public_ip["pip_fgt_a_mgmt"].public_ip.id
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
          public_ip_address_id          = module.module_azurerm_public_ip["pip_fgt_b_mgmt"].public_ip.id
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
    "nsr_internal_iegress" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name

      name                        = "nsr_internal_iegress"
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
    "hasync" = {
      subnet_id                 = module.module_azurerm_subnet["hasync"].subnet.id
      network_security_group_id = module.module_azurerm_network_security_group["nsg_internal"].network_security_group.id
    }
    "mgmt" = {
      subnet_id                 = module.module_azurerm_subnet["mgmt"].subnet.id
      network_security_group_id = module.module_azurerm_network_security_group["nsg_internal"].network_security_group.id
    }
  }

  # used as the suffix part of the storage account name
  random_ids = {
    "storage_account_random_id" = {
      keepers_resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      byte_length                 = 8
    }
  }

  # storage account must be globally unique
  # capital letters, dashes, uderscores, etc. are not allowed in storage account names
  storage_accounts = {
    "stdiag" = {
      resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
      location            = module.module_azurerm_resource_group[var.resource_group_name].resource_group.location

      name                     = format("stdiag%s", "${random_id.id["storage_account_random_id"].hex}")
      account_replication_type = "LRS"
      account_tier             = "Standard"
    }
  }

  vm_image = {
    "fortinet" = {
      publisher = "fortinet"
      offer     = "fortinet_fortigate-vm_v5"
      sku       = "fortinet_fg-vm_payg_20190624"
      version   = "7.0.5"
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

      network_interface_ids        = [for nic in ["nic_fortigate_1_1", "nic_fortigate_1_2", "nic_fortigate_1_3", "nic_fortigate_1_4"] : module.module_azurerm_network_interface[nic].network_interface.id]
      primary_network_interface_id = module.module_azurerm_network_interface["nic_fortigate_1_1"].network_interface.id

      public_ip_address = module.module_azurerm_public_ip["pip_fgt_a_mgmt"].public_ip.ip_address

      vm_size = "Standard_F4s"

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

      boot_diagnostics_enabled     = true
      boot_diagnostics_storage_uri = module.module_azurerm_storage_account["stdiag"].storage_account.primary_blob_endpoint

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
      config_data = templatefile(
        "./fortios_config.conf", {
          host_name               = "vm-fgt-1"
          connect_to_fmg          = var.connect_to_fmg
          license_type            = var.license_type
          forti_manager_ip        = var.forti_manager_ip
          forti_manager_serial    = var.forti_manager_serial
          license_file            = ""
          serial_number           = ""
          license_token           = ""
          api_key                 = random_string.string.id
          vnet_address_prefix     = module.module_azurerm_virtual_network["vnet_security"].virtual_network.address_space[0]
          external_subnet_gateway = cidrhost(module.module_azurerm_subnet["external"].subnet.address_prefixes[0], 1)
          internal_subnet_gateway = cidrhost(module.module_azurerm_subnet["internal"].subnet.address_prefixes[0], 1)
          port1_ip                = module.module_azurerm_network_interface["nic_fortigate_1_1"].network_interface.private_ip_address
          port1_netmask           = cidrnetmask(module.module_azurerm_subnet["external"].subnet.address_prefixes[0])
          port2_ip                = module.module_azurerm_network_interface["nic_fortigate_1_2"].network_interface.private_ip_address
          port2_netmask           = cidrnetmask(module.module_azurerm_subnet["internal"].subnet.address_prefixes[0])
          port3_ip                = module.module_azurerm_network_interface["nic_fortigate_1_3"].network_interface.private_ip_address
          port3_netmask           = cidrnetmask(module.module_azurerm_subnet["hasync"].subnet.address_prefixes[0])
          port4_ip                = module.module_azurerm_network_interface["nic_fortigate_1_4"].network_interface.private_ip_address
          port4_netmask           = cidrnetmask(module.module_azurerm_subnet["mgmt"].subnet.address_prefixes[0])
          mgmt_subnet_gateway     = cidrhost(module.module_azurerm_subnet["mgmt"].subnet.address_prefixes[0], 1)
          ha_priority             = 255
          ha_peer                 = module.module_azurerm_network_interface["nic_fortigate_2_3"].network_interface.private_ip_address
          sdn_resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
          sdn_nic_name            = module.module_azurerm_network_interface["nic_fortigate_1_1"].network_interface.name
          sdn_nic_config_name     = "ipconfig1"
          sdn_public_ip_name      = module.module_azurerm_public_ip["pip_fgt"].public_ip.name
          sdn_route_table_name    = module.module_azurerm_route_table["rt_protected"].route_table.name
          sdn_route_name          = module.module_azurerm_route["r_default"].route.name
          snd_next_hop_ip         = module.module_azurerm_network_interface["nic_fortigate_1_2"].network_interface.private_ip_address
          sdn_subscription_id     = data.azurerm_subscription.subscription.subscription_id
        }
      )
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

      network_interface_ids        = [for nic in ["nic_fortigate_2_1", "nic_fortigate_2_2", "nic_fortigate_2_3", "nic_fortigate_2_4"] : module.module_azurerm_network_interface[nic].network_interface.id]
      primary_network_interface_id = module.module_azurerm_network_interface["nic_fortigate_2_1"].network_interface.id

      public_ip_address = module.module_azurerm_public_ip["pip_fgt_b_mgmt"].public_ip.ip_address

      vm_size = "Standard_F4s"

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

      boot_diagnostics_enabled     = true
      boot_diagnostics_storage_uri = module.module_azurerm_storage_account["stdiag"].storage_account.primary_blob_endpoint

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
      config_data = templatefile(
        "./fortios_config.conf", {
          host_name               = "vm-fgt-2"
          connect_to_fmg          = var.connect_to_fmg
          license_type            = var.license_type
          forti_manager_ip        = var.forti_manager_ip
          forti_manager_serial    = var.forti_manager_serial
          license_file            = ""
          serial_number           = ""
          license_token           = ""
          api_key                 = random_string.string.id
          vnet_address_prefix     = module.module_azurerm_virtual_network["vnet_security"].virtual_network.address_space[0]
          external_subnet_gateway = cidrhost(module.module_azurerm_subnet["external"].subnet.address_prefixes[0], 1)
          internal_subnet_gateway = cidrhost(module.module_azurerm_subnet["internal"].subnet.address_prefixes[0], 1)
          port1_ip                = module.module_azurerm_network_interface["nic_fortigate_2_1"].network_interface.private_ip_address
          port1_netmask           = cidrnetmask(module.module_azurerm_subnet["external"].subnet.address_prefixes[0])
          port2_ip                = module.module_azurerm_network_interface["nic_fortigate_2_2"].network_interface.private_ip_address
          port2_netmask           = cidrnetmask(module.module_azurerm_subnet["internal"].subnet.address_prefixes[0])
          port3_ip                = module.module_azurerm_network_interface["nic_fortigate_2_3"].network_interface.private_ip_address
          port3_netmask           = cidrnetmask(module.module_azurerm_subnet["hasync"].subnet.address_prefixes[0])
          port4_ip                = module.module_azurerm_network_interface["nic_fortigate_2_4"].network_interface.private_ip_address
          port4_netmask           = cidrnetmask(module.module_azurerm_subnet["mgmt"].subnet.address_prefixes[0])
          mgmt_subnet_gateway     = cidrhost(module.module_azurerm_subnet["mgmt"].subnet.address_prefixes[0], 1)
          ha_priority             = 1
          ha_peer                 = module.module_azurerm_network_interface["nic_fortigate_1_3"].network_interface.private_ip_address
          sdn_resource_group_name = module.module_azurerm_resource_group[var.resource_group_name].resource_group.name
          sdn_nic_name            = module.module_azurerm_network_interface["nic_fortigate_2_1"].network_interface.name
          sdn_nic_config_name     = "ipconfig1"
          sdn_public_ip_name      = module.module_azurerm_public_ip["pip_fgt"].public_ip.name
          sdn_route_table_name    = module.module_azurerm_route_table["rt_protected"].route_table.name
          sdn_route_name          = module.module_azurerm_route["r_default"].route.name
          snd_next_hop_ip         = module.module_azurerm_network_interface["nic_fortigate_2_2"].network_interface.private_ip_address
          sdn_subscription_id     = data.azurerm_subscription.subscription.subscription_id
        }
      )
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