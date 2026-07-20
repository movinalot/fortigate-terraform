locals {

  username = var.username
  password = var.password

  resource_group_name     = var.resource_group_name
  resource_group_location = "eastus"

  virtual_network_name = "vnet-security"

  # FortiGate License files are expected to be in
  # the same folder as this file when using byol

  fortigate_license_file  = var.fortigate_license_file
  fortigate_license_token = var.fortigate_license_token
  fortigate_license_type  = "flex" # can be "byol", "flex", or "payg"

  connect_to_fmg       = "" # set to "true" to connect to FortiManager
  forti_manager_ip     = ""
  forti_manager_serial = ""

  # Refer to the README.md for details on the correct image reference for byol/flex or payg images.
  vm_image = {
    "fortigate" = {
      publisher = "fortinet"
      offer     = "fortinet_fortigate-vm"
      sku       = "fortinet_fg-vm_byol_80_g2"

      vm_size = "Standard_F2als_v7"
      version = "latest" # can be a version number, refer to README.md
    }
  }

  resource_groups = {
    "${local.resource_group_name}" = {
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
      address_space = ["172.16.136.0/22"]
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
    "snet-protected" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name

      name                 = "snet-protected"
      virtual_network_name = azurerm_virtual_network.virtual_network[local.virtual_network_name].name
      address_prefixes     = [cidrsubnet(tolist(azurerm_virtual_network.virtual_network[local.virtual_network_name].address_space)[0], 2, 1)]
    }
  }

  network_interfaces = {
    "nic-fortigate_ext" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name                           = "nic-fortigate_ext"
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
    "nic-fortigate_int" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name                           = "nic-fortigate_int"
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
  }

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
      next_hop_in_ip_address = azurerm_network_interface.network_interface["nic-fortigate_int"].private_ip_address
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
  }

  linux_virtual_machines = {
    "vm-fgt" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name                  = "vm-fgt"
      network_interface_ids = [for nic in ["nic-fortigate_ext", "nic-fortigate_int"] : azurerm_network_interface.network_interface[nic].id]

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

      os_disk_name                 = "osdisk-fgt"
      os_disk_caching              = "ReadWrite"
      os_disk_storage_account_type = "Premium_LRS"

      identity_type                        = "SystemAssigned"
      boot_diagnostics_storage_account_uri = ""

      custom_data = templatefile(
        "${path.module}/fortios_config.conf", {
          host_name               = "vm-fgt"
          connect_to_fmg          = local.forti_manager_ip != "" && local.forti_manager_serial != "" ? local.connect_to_fmg : "true"
          license_type            = local.fortigate_license_type
          forti_manager_ip        = local.forti_manager_ip
          forti_manager_serial    = local.forti_manager_serial
          license_file            = local.fortigate_license_file
          license_token           = local.fortigate_license_token
          api_key                 = random_string.string.id
          vnet_address_prefix     = tolist(azurerm_virtual_network.virtual_network["vnet-security"].address_space)[0]
          external_subnet_gateway = cidrhost(azurerm_subnet.subnet["snet-external"].address_prefixes[0], 1)
          internal_subnet_gateway = cidrhost(azurerm_subnet.subnet["snet-internal"].address_prefixes[0], 1)
          port1_ip                = azurerm_network_interface.network_interface["nic-fortigate_ext"].private_ip_address
          port1_netmask           = cidrnetmask(azurerm_subnet.subnet["snet-external"].address_prefixes[0])
          port2_ip                = azurerm_network_interface.network_interface["nic-fortigate_int"].private_ip_address
          port2_netmask           = cidrnetmask(azurerm_subnet.subnet["snet-internal"].address_prefixes[0])
        }
      )
    }
  }

  managed_disks = {
    "data_disk-fgt" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name                 = "data_disk-fgt"
      storage_account_type = "Premium_LRS"
      create_option        = "Empty"
      disk_size_gb         = 30
    }
  }

  virtual_machine_data_disk_attachments = {
    "data_disk-fgt" = {
      managed_disk_id    = azurerm_managed_disk.managed_disk["data_disk-fgt"].id
      virtual_machine_id = azurerm_linux_virtual_machine.linux_virtual_machine["vm-fgt"].id
      lun                = 0
      caching            = "ReadWrite"
    }
  }

  role_assignments = {
    "vm-fgt" = {
      scope                = azurerm_resource_group.resource_group[local.resource_group_name].id
      role_definition_name = "Contributor"
      principal_id         = azurerm_linux_virtual_machine.linux_virtual_machine["vm-fgt"].identity[0].principal_id
    }
  }
}