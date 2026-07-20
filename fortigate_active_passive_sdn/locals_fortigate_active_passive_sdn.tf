locals {

  username = var.username
  password = var.password

  resource_group_name     = "rg-fortigate_ap_sdn"
  resource_group_location = "eastus"

  virtual_network_name = "vnet-security"

  # FortiGate License files are expected to be in
  # the same folder as this file when using byol

  fortigate_1_license_file = ""
  fortigate_2_license_file = ""

  fortigate_1_license_token = ""
  fortigate_2_license_token = ""

  connect_to_fmg       = "" # set to "true" to connect to FortiManager
  forti_manager_ip     = ""
  forti_manager_serial = ""
  admin-sport          = ""

  # Refer to the README.md for details on the correct image reference for byol/flex or payg images.
  vm_image = {
    "fortigate" = {
      publisher = "fortinet"
      offer     = "fortinet_fortigate-vm"
      sku       = "fortinet_fg-vm_payg_80_g2"
      vm_size   = "Standard_F2als_v7"
      version   = "latest" # can be a version number, refer to README.md
    }
  }

  resource_groups = {
    "rg-fortigate_ap_sdn" = {
      name     = local.resource_group_name
      location = local.resource_group_location
    }
  }

  public_ips = {
    "pip-fgt" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name              = "pip-fgt"
      allocation_method = "Static"
      sku               = "Standard"
    }
    "pip-fgt_1_mgmt" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name              = "pip-fgt_1_mgmt"
      allocation_method = "Static"
      sku               = "Standard"
    }
    "pip-fgt_2_mgmt" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name              = "pip-fgt_2_mgmt"
      allocation_method = "Static"
      sku               = "Standard"
    }
  }

  availability_set = false # set to true to availability sets
  availability_sets = {
    "avail-1" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name                         = "avail-1"
      platform_update_domain_count = "2"
      platform_fault_domain_count  = "2"
      proximity_placement_group_id = null
      managed                      = true
    }
  }

  virtual_networks = {
    "vnet-security" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name          = local.virtual_network_name
      address_space = ["172.16.16.0/22"]
    }
  }

  subnets = {
    "snet-external" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name

      name                 = "snet-external"
      virtual_network_name = azurerm_virtual_network.virtual_network[local.virtual_network_name].name
      address_prefixes     = [cidrsubnet(tolist(azurerm_virtual_network.virtual_network[local.virtual_network_name].address_space)[0], 4, 0)]

    }
    "snet-internal" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name

      name                 = "snet-internal"
      virtual_network_name = azurerm_virtual_network.virtual_network[local.virtual_network_name].name
      address_prefixes     = [cidrsubnet(tolist(azurerm_virtual_network.virtual_network[local.virtual_network_name].address_space)[0], 4, 1)]
    }
    "snet-hasync-mgmt" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name

      name                 = "snet-hasync-mgmt"
      virtual_network_name = azurerm_virtual_network.virtual_network[local.virtual_network_name].name
      address_prefixes     = [cidrsubnet(tolist(azurerm_virtual_network.virtual_network[local.virtual_network_name].address_space)[0], 4, 2)]
    }

    "snet-protected" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name

      name                 = "snet-protected"
      virtual_network_name = azurerm_virtual_network.virtual_network[local.virtual_network_name].name
      address_prefixes     = [cidrsubnet(tolist(azurerm_virtual_network.virtual_network[local.virtual_network_name].address_space)[0], 2, 1)]
    }
  }

  network_interfaces = {
    "nic-fortigate_1_ext" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name                           = "nic-fortigate_1_ext"
      ip_forwarding_enabled          = true
      accelerated_networking_enabled = true
      ip_configurations = [
        {
          name                          = "ipconfig1"
          primary                       = true
          subnet_id                     = azurerm_subnet.subnet["snet-external"].id
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(azurerm_subnet.subnet["snet-external"].address_prefixes[0], 4)
          public_ip_address_id          = azurerm_public_ip.public_ip["pip-fgt"].id
        }
      ]
    }
    "nic-fortigate_1_int" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name                           = "nic-fortigate_1_int"
      ip_forwarding_enabled          = true
      accelerated_networking_enabled = true
      ip_configurations = [
        {
          name                          = "ipconfig1"
          primary                       = true
          subnet_id                     = azurerm_subnet.subnet["snet-internal"].id
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(azurerm_subnet.subnet["snet-internal"].address_prefixes[0], 4)
          public_ip_address_id          = null
        }
      ]
    }
    "nic-fortigate_1_hasync-mgmt" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name                           = "nic-fortigate_1_hasync-mgmt"
      ip_forwarding_enabled          = true
      accelerated_networking_enabled = true
      ip_configurations = [
        {
          name                          = "ipconfig1"
          primary                       = true
          subnet_id                     = azurerm_subnet.subnet["snet-hasync-mgmt"].id
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(azurerm_subnet.subnet["snet-hasync-mgmt"].address_prefixes[0], 4)
          public_ip_address_id          = null
        }
      ]
    }

    "nic-fortigate_2_ext" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name                           = "nic-fortigate_2_ext"
      ip_forwarding_enabled          = true
      accelerated_networking_enabled = true
      ip_configurations = [
        {
          name                          = "ipconfig1"
          primary                       = true
          subnet_id                     = azurerm_subnet.subnet["snet-external"].id
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(azurerm_subnet.subnet["snet-external"].address_prefixes[0], 5)
          public_ip_address_id          = null
        }
      ]
    }
    "nic-fortigate_2_int" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name                           = "nic-fortigate_2_int"
      ip_forwarding_enabled          = true
      accelerated_networking_enabled = true
      ip_configurations = [
        {
          name                          = "ipconfig1"
          primary                       = true
          subnet_id                     = azurerm_subnet.subnet["snet-internal"].id
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(azurerm_subnet.subnet["snet-internal"].address_prefixes[0], 5)
          public_ip_address_id          = null
        }
      ]
    }
    "nic-fortigate_2_hasync-mgmt" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name                           = "nic-fortigate_2_hasync-mgmt"
      ip_forwarding_enabled          = true
      accelerated_networking_enabled = true
      ip_configurations = [
        {
          name                          = "ipconfig1"
          primary                       = true
          subnet_id                     = azurerm_subnet.subnet["snet-hasync-mgmt"].id
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(azurerm_subnet.subnet["snet-hasync-mgmt"].address_prefixes[0], 5)
          public_ip_address_id          = null
        }
      ]
    }

  }

  floating_private_ip_address = cidrhost(azurerm_subnet.subnet["snet-internal"].address_prefixes[0], 6)

  route_tables = {
    "rt-protected" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name = "rt-protected"
    }
  }

  routes = {
    "udr-default" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name

      name                   = "udr-default"
      address_prefix         = "0.0.0.0/0"
      next_hop_in_ip_address = local.floating_private_ip_address
      next_hop_type          = "VirtualAppliance"
      route_table_name       = azurerm_route_table.route_table["rt-protected"].name
    }
  }

  subnet_route_table_associations = {
    "snet-protected" = {
      subnet_id      = azurerm_subnet.subnet["snet-protected"].id
      route_table_id = azurerm_route_table.route_table["rt-protected"].id
    }
  }

  network_security_groups = {
    "nsg-external" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name = "nsg-external"
    }
    "nsg-internal" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name = "nsg-internal"
    }
  }

  network_security_rules = {
    "nsgsr-external_ingress" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name

      name                        = "nsgsr-external_ingress"
      priority                    = 1001
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
      network_security_group_name = azurerm_network_security_group.network_security_group["nsg-external"].name
    },
    "nsgsr-external_egress" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name

      name                        = "nsgsr-external_egress"
      priority                    = 1002
      direction                   = "Outbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
      network_security_group_name = azurerm_network_security_group.network_security_group["nsg-external"].name
    },
    "nsgsr-internal_ingress" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name

      name                        = "nsgsr-internal_ingress"
      priority                    = 1003
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
      network_security_group_name = azurerm_network_security_group.network_security_group["nsg-internal"].name
    },
    "nsgsr-internal_egress" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name

      name                        = "nsgsr-internal_egress"
      priority                    = 1004
      direction                   = "Outbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
      network_security_group_name = azurerm_network_security_group.network_security_group["nsg-internal"].name
    }
  }

  subnet_network_security_group_associations = {
    "snet-external" = {
      subnet_id                 = azurerm_subnet.subnet["snet-external"].id
      network_security_group_id = azurerm_network_security_group.network_security_group["nsg-external"].id
    }
    "snet-internal" = {
      subnet_id                 = azurerm_subnet.subnet["snet-internal"].id
      network_security_group_id = azurerm_network_security_group.network_security_group["nsg-internal"].id
    }
    "snet-hasync-mgmt" = {
      subnet_id                 = azurerm_subnet.subnet["snet-hasync-mgmt"].id
      network_security_group_id = azurerm_network_security_group.network_security_group["nsg-internal"].id
    }
  }

  linux_virtual_machines = {
    "vm-fgt-1" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name                  = "vm-fgt-1"
      network_interface_ids = [for nic in ["nic-fortigate_1_ext", "nic-fortigate_1_int", "nic-fortigate_1_hasync-mgmt"] : azurerm_network_interface.network_interface[nic].id]

      size = local.vm_image["fortigate"].vm_size

      username = var.username
      password = var.password

      disable_password_authentication = false

      source_image_reference_publisher = local.vm_image["fortigate"].publisher
      source_image_reference_offer     = local.vm_image["fortigate"].offer
      source_image_reference_sku       = local.vm_image["fortigate"].sku
      source_image_reference_version   = local.vm_image["fortigate"].version

      plan = [{
        publisher = local.vm_image["fortigate"].publisher
        product   = local.vm_image["fortigate"].offer
        name      = local.vm_image["fortigate"].sku
      }]

      os_disk_name                 = "osdisk-fgt-1"
      os_disk_caching              = "ReadWrite"
      os_disk_storage_account_type = "Premium_LRS"

      identity_type = "SystemAssigned"
      boot_diagnostics_storage_account_uri = ""

      custom_data = templatefile(
        "./fortios_config.conf", {
          host_name               = "vm-fgt-1"
          connect_to_fmg          = local.connect_to_fmg
          forti_manager_ip        = local.forti_manager_ip
          forti_manager_serial    = local.forti_manager_serial
          license_type            = substr(local.vm_image["fortigate"].sku, 15, 4)
          license_file            = local.fortigate_1_license_file
          license_token           = local.fortigate_1_license_token
          api_key                 = random_string.string.id
          vnet_address_prefix     = tolist(azurerm_virtual_network.virtual_network["vnet-security"].address_space)[0]
          external_subnet_gateway = cidrhost(azurerm_subnet.subnet["snet-external"].address_prefixes[0], 1)
          internal_subnet_gateway = cidrhost(azurerm_subnet.subnet["snet-internal"].address_prefixes[0], 1)
          port1_ip                = azurerm_network_interface.network_interface["nic-fortigate_1_ext"].private_ip_address
          port1_netmask           = cidrnetmask(azurerm_subnet.subnet["snet-external"].address_prefixes[0])
          port2_ip                = azurerm_network_interface.network_interface["nic-fortigate_1_int"].private_ip_address
          port2_netmask           = cidrnetmask(azurerm_subnet.subnet["snet-internal"].address_prefixes[0])
          port3_ip                = azurerm_network_interface.network_interface["nic-fortigate_1_hasync-mgmt"].private_ip_address
          port3_netmask           = cidrnetmask(azurerm_subnet.subnet["snet-hasync-mgmt"].address_prefixes[0])
          hasync_mgmt_subnet_gateway     = cidrhost(azurerm_subnet.subnet["snet-hasync-mgmt"].address_prefixes[0], 1)
          ha_password             = local.password
          ha_peer                 = azurerm_network_interface.network_interface["nic-fortigate_2_hasync-mgmt"].private_ip_address
          ha_priority             = 255
          sdn_resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
          sdn_nic1_name           = azurerm_network_interface.network_interface["nic-fortigate_1_ext"].name
          sdn_nic1_config_name    = "ipconfig1"
          sdn_nic2_name           = azurerm_network_interface.network_interface["nic-fortigate_1_int"].name
          sdn_peer_nic2_name      = azurerm_network_interface.network_interface["nic-fortigate_2_int"].name
          sdn_floating_ip_config  = "ipconfig2"
          sdn_floating_ip         = local.floating_private_ip_address
          sdn_public_ip_name      = azurerm_public_ip.public_ip["pip-fgt"].name
          sdn_subscription_id     = data.azurerm_subscription.subscription.subscription_id
        }
      )
    }
    "vm-fgt-2" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name                  = "vm-fgt-2"
      network_interface_ids = [for nic in ["nic-fortigate_2_ext", "nic-fortigate_2_int", "nic-fortigate_2_hasync-mgmt"] : azurerm_network_interface.network_interface[nic].id]

      size = local.vm_image["fortigate"].vm_size

      username = var.username
      password = var.password

      disable_password_authentication = false

      source_image_reference_publisher = local.vm_image["fortigate"].publisher
      source_image_reference_offer     = local.vm_image["fortigate"].offer
      source_image_reference_sku       = local.vm_image["fortigate"].sku
      source_image_reference_version   = local.vm_image["fortigate"].version

      plan = [{
        publisher = local.vm_image["fortigate"].publisher
        product   = local.vm_image["fortigate"].offer
        name      = local.vm_image["fortigate"].sku
      }]

      os_disk_name                 = "osdisk-fgt-2"
      os_disk_caching              = "ReadWrite"
      os_disk_storage_account_type = "Premium_LRS"

      identity_type = "SystemAssigned"
      boot_diagnostics_storage_account_uri = ""

      custom_data = templatefile(
        "./fortios_config.conf", {
          host_name               = "vm-fgt-2"
          connect_to_fmg          = local.connect_to_fmg
          forti_manager_ip        = local.forti_manager_ip
          forti_manager_serial    = local.forti_manager_serial
          license_type            = substr(local.vm_image["fortigate"].sku, 15, 4)
          license_file            = local.fortigate_2_license_file
          license_token           = local.fortigate_2_license_token
          api_key                 = random_string.string.id
          vnet_address_prefix     = tolist(azurerm_virtual_network.virtual_network["vnet-security"].address_space)[0]
          external_subnet_gateway = cidrhost(azurerm_subnet.subnet["snet-external"].address_prefixes[0], 1)
          internal_subnet_gateway = cidrhost(azurerm_subnet.subnet["snet-internal"].address_prefixes[0], 1)
          port1_ip                = azurerm_network_interface.network_interface["nic-fortigate_2_ext"].private_ip_address
          port1_netmask           = cidrnetmask(azurerm_subnet.subnet["snet-external"].address_prefixes[0])
          port2_ip                = azurerm_network_interface.network_interface["nic-fortigate_2_int"].private_ip_address
          port2_netmask           = cidrnetmask(azurerm_subnet.subnet["snet-internal"].address_prefixes[0])
          port3_ip                = azurerm_network_interface.network_interface["nic-fortigate_2_hasync-mgmt"].private_ip_address
          port3_netmask           = cidrnetmask(azurerm_subnet.subnet["snet-hasync-mgmt"].address_prefixes[0])
          hasync_mgmt_subnet_gateway     = cidrhost(azurerm_subnet.subnet["snet-hasync-mgmt"].address_prefixes[0], 1)
          ha_password             = local.password
          ha_peer                 = azurerm_network_interface.network_interface["nic-fortigate_1_hasync-mgmt"].private_ip_address
          ha_priority             = 1
          sdn_resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
          sdn_nic1_name           = azurerm_network_interface.network_interface["nic-fortigate_2_ext"].name
          sdn_nic1_config_name    = "ipconfig1"
          sdn_nic2_name           = azurerm_network_interface.network_interface["nic-fortigate_2_int"].name
          sdn_peer_nic2_name      = azurerm_network_interface.network_interface["nic-fortigate_1_int"].name
          sdn_floating_ip_config  = "ipconfig2"
          sdn_floating_ip         = local.floating_private_ip_address
          sdn_public_ip_name      = azurerm_public_ip.public_ip["pip-fgt"].name
          sdn_subscription_id     = data.azurerm_subscription.subscription.subscription_id
        }
      )
    }
  }

  managed_disks = {
    "data_disk-fgt-1" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name                 = "data_disk-fgt-1"
      storage_account_type = "Premium_LRS"
      create_option        = "Empty"
      disk_size_gb         = 30
    }
    "data_disk-fgt-2" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name                 = "data_disk-fgt-2"
      storage_account_type = "Premium_LRS"
      create_option        = "Empty"
      disk_size_gb         = 30
    }
  }

  virtual_machine_data_disk_attachments = {
    "data_disk-fgt-1" = {
      managed_disk_id    = azurerm_managed_disk.managed_disk["data_disk-fgt-1"].id
      virtual_machine_id = azurerm_linux_virtual_machine.linux_virtual_machine["vm-fgt-1"].id
      lun                = 0
      caching            = "ReadWrite"
    }
    "data_disk-fgt-2" = {
      managed_disk_id    = azurerm_managed_disk.managed_disk["data_disk-fgt-2"].id
      virtual_machine_id = azurerm_linux_virtual_machine.linux_virtual_machine["vm-fgt-2"].id
      lun                = 0
      caching            = "ReadWrite"
    }
  }

  role_assignments = {
    "vm-fgt-1" = {
      scope = data.azurerm_subscription.subscription.id
      #scope                = azurerm_resource_group.resource_group[local.resource_group_name].id
      role_definition_name = "Contributor"
      principal_id         = azurerm_linux_virtual_machine.linux_virtual_machine["vm-fgt-1"].identity[0].principal_id
    }
    "vm-fgt-2" = {
      scope = data.azurerm_subscription.subscription.id
      #scope                = azurerm_resource_group.resource_group[local.resource_group_name].id
      role_definition_name = "Contributor"
      principal_id         = azurerm_linux_virtual_machine.linux_virtual_machine["vm-fgt-2"].identity[0].principal_id
    }
  }
}