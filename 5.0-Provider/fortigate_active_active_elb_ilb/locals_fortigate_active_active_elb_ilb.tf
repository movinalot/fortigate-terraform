locals {

  username = var.username
  password = var.password

  resource_group_name     = var.resource_group_name
  resource_group_location = "eastus"

  virtual_network_name = "vnet-security"

  # FortiGate License files are expected to be in
  # the same folder as this file when using byol

  fortigate_1_license_file = var.fortigate_1_license_file
  fortigate_2_license_file = var.fortigate_2_license_file

  fortigate_1_license_token = var.fortigate_1_license_token
  fortigate_2_license_token = var.fortigate_2_license_token
  fortigate_license_type    = "payg" # can be "byol", "flex", or "payg"

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
    "${local.resource_group_name}" = {
      name     = local.resource_group_name
      location = local.resource_group_location
      tags     = var.tags
    }
  }

  public_ips = {
    "pip-elb" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name              = "pip-elb"
      allocation_method = "Static"
      sku               = "Standard"
      zones             = ["1", "2", "3"]
    }
    "pip-fgt_1_mgmt" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name              = "pip-fgt_1_mgmt"
      allocation_method = "Static"
      sku               = "Standard"
      zones             = ["1", "2", "3"]
    }
    "pip-fgt_2_mgmt" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name              = "pip-fgt_2_mgmt"
      allocation_method = "Static"
      sku               = "Standard"
      zones             = ["1", "2", "3"]
    }
  }

  vm-fgt-1_availability_zone = "1"
  vm-fgt-2_availability_zone = "3"

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
          public_ip_address_id          = azurerm_public_ip.public_ip["pip-fgt_1_mgmt"].id
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
          public_ip_address_id          = azurerm_public_ip.public_ip["pip-fgt_2_mgmt"].id
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
  }

  lbs = {
    "lbe-external" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name = "lbe-external"
      sku  = "Standard"
      frontend_ip_configurations = [
        {
          name                 = "lbe-external_fe_ip"
          public_ip_address_id = azurerm_public_ip.public_ip["pip-elb"].id
        }
      ]
    }

    "lbi-internal" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name = "lbi-internal"
      sku  = "Standard"
      frontend_ip_configurations = [
        {
          name                          = "lbi-internal_fe_ip"
          subnet_id                     = azurerm_subnet.subnet["snet-internal"].id
          vnet_name                     = azurerm_virtual_network.virtual_network["vnet-security"].name
          private_ip_address            = cidrhost(azurerm_subnet.subnet["snet-internal"].address_prefixes[0], 6)
          private_ip_address_allocation = "Static"
          private_ip_address_version    = "IPv4"
        }
      ]
    }
  }

  lb_backend_address_pools = {
    "lbe-external_pool" = {
      name            = "lbe-external_pool"
      loadbalancer_id = azurerm_lb.lb["lbe-external"].id
    }
    "lbi-internal_pool" = {
      name            = "lbi-internal_pool"
      loadbalancer_id = azurerm_lb.lb["lbi-internal"].id
    }
  }

  network_interface_backend_address_pool_associations = {
    "nic-fortigate_1_ext" = {
      network_interface_id    = azurerm_network_interface.network_interface["nic-fortigate_1_ext"].id
      ip_configuration_name   = "ipconfig1"
      backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend_address_pool["lbe-external_pool"].id
    }
    "nic-fortigate_2_ext" = {
      network_interface_id    = azurerm_network_interface.network_interface["nic-fortigate_2_ext"].id
      ip_configuration_name   = "ipconfig1"
      backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend_address_pool["lbe-external_pool"].id
    }
    "nic-fortigate_1_int" = {
      network_interface_id    = azurerm_network_interface.network_interface["nic-fortigate_1_int"].id
      ip_configuration_name   = "ipconfig1"
      backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend_address_pool["lbi-internal_pool"].id
    }
    "nic-fortigate_2_int" = {
      network_interface_id    = azurerm_network_interface.network_interface["nic-fortigate_2_int"].id
      ip_configuration_name   = "ipconfig1"
      backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend_address_pool["lbi-internal_pool"].id
    }
  }

  lb_probes = {
    "lbe-external_probe" = {
      name                = "lbe-external_probe"
      loadbalancer_id     = azurerm_lb.lb["lbe-external"].id
      port                = "8008"
      interval_in_seconds = 5
    }
    "lbi-internal_probe" = {
      name                = "lbi-internal_probe"
      loadbalancer_id     = azurerm_lb.lb["lbi-internal"].id
      port                = "8008"
      interval_in_seconds = 5
    }
  }

  lb_rules = {
    "rule-tcp_80" = {
      resource_group_name            = azurerm_resource_group.resource_group[local.resource_group_name].name
      name                           = "rule-tcp_80"
      loadbalancer_id                = azurerm_lb.lb["lbe-external"].id
      frontend_ip_configuration_name = "lbe-external_fe_ip"
      protocol                       = "Tcp"
      frontend_port                  = "80"
      backend_port                   = "80"
      backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb_backend_address_pool["lbe-external_pool"].id]
      probe_id                       = azurerm_lb_probe.lb_probe["lbe-external_probe"].id
      disable_outbound_snat          = true
    }
    "rule-udp_10551" = {
      resource_group_name            = azurerm_resource_group.resource_group[local.resource_group_name].name
      name                           = "rule-udp_10551"
      loadbalancer_id                = azurerm_lb.lb["lbe-external"].id
      frontend_ip_configuration_name = "lbe-external_fe_ip"
      protocol                       = "Udp"
      frontend_port                  = "10551"
      backend_port                   = "10551"
      backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb_backend_address_pool["lbe-external_pool"].id]
      probe_id                       = azurerm_lb_probe.lb_probe["lbe-external_probe"].id
      disable_outbound_snat          = true
    }
    "rule-haports" = {
      resource_group_name            = azurerm_resource_group.resource_group[local.resource_group_name].name
      name                           = "rule-haports"
      loadbalancer_id                = azurerm_lb.lb["lbi-internal"].id
      frontend_ip_configuration_name = "lbi-internal_fe_ip"
      protocol                       = "All"
      frontend_port                  = "0"
      backend_port                   = "0"
      backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb_backend_address_pool["lbi-internal_pool"].id]
      probe_id                       = azurerm_lb_probe.lb_probe["lbi-internal_probe"].id
      disable_outbound_snat          = true
    }
  }

  lb_nat_rules = {
    "fgt_1_https" = {
      resource_group_name            = local.resource_group_name
      name                           = "fgt_1_https"
      loadbalancer_id                = azurerm_lb.lb["lbe-external"].id
      protocol                       = "Tcp"
      frontend_port                  = "10443"
      backend_port                   = "443"
      frontend_ip_configuration_name = "lbe-external_fe_ip"
    }
    "fgt_2_https" = {
      resource_group_name            = local.resource_group_name
      name                           = "fgt_2_https"
      loadbalancer_id                = azurerm_lb.lb["lbe-external"].id
      protocol                       = "Tcp"
      frontend_port                  = "20443"
      backend_port                   = "443"
      frontend_ip_configuration_name = "lbe-external_fe_ip"
    }
    "fgt_1_ssh" = {
      resource_group_name            = local.resource_group_name
      name                           = "fgt_1_ssh"
      loadbalancer_id                = azurerm_lb.lb["lbe-external"].id
      protocol                       = "Tcp"
      frontend_port                  = "10022"
      backend_port                   = "22"
      frontend_ip_configuration_name = "lbe-external_fe_ip"
    }
    "fgt_2_ssh" = {
      resource_group_name            = local.resource_group_name
      name                           = "fgt_2_ssh"
      loadbalancer_id                = azurerm_lb.lb["lbe-external"].id
      protocol                       = "Tcp"
      frontend_port                  = "20022"
      backend_port                   = "22"
      frontend_ip_configuration_name = "lbe-external_fe_ip"
    }
  }

  network_interface_nat_rule_associations = {
    "fgt_1_https" = {
      network_interface_id  = azurerm_network_interface.network_interface["nic-fortigate_1_ext"].id
      ip_configuration_name = "ipconfig1"
      nat_rule_id           = azurerm_lb_nat_rule.lb_nat_rule["fgt_1_https"].id
    }
    "fgt_2_https" = {
      network_interface_id  = azurerm_network_interface.network_interface["nic-fortigate_2_ext"].id
      ip_configuration_name = "ipconfig1"
      nat_rule_id           = azurerm_lb_nat_rule.lb_nat_rule["fgt_2_https"].id
    }
    "fgt_1_ssh" = {
      network_interface_id  = azurerm_network_interface.network_interface["nic-fortigate_1_ext"].id
      ip_configuration_name = "ipconfig1"
      nat_rule_id           = azurerm_lb_nat_rule.lb_nat_rule["fgt_1_ssh"].id
    }
    "fgt_2_ssh" = {
      network_interface_id  = azurerm_network_interface.network_interface["nic-fortigate_2_ext"].id
      ip_configuration_name = "ipconfig1"
      nat_rule_id           = azurerm_lb_nat_rule.lb_nat_rule["fgt_2_ssh"].id
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
      next_hop_in_ip_address = azurerm_lb.lb["lbi-internal"].frontend_ip_configuration[0].private_ip_address
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
    "nsg-security" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name = "nsg-security"
    }
  }

  network_security_rules = {
    "nsgsr-ingress" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name

      name                        = "nsgsr-ingress"
      priority                    = 1001
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
      network_security_group_name = azurerm_network_security_group.network_security_group["nsg-security"].name
    },
    "nsgsr-egress" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name

      name                        = "nsgsr-egress"
      priority                    = 1002
      direction                   = "Outbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
      network_security_group_name = azurerm_network_security_group.network_security_group["nsg-security"].name
    }
  }

  subnet_network_security_group_associations = {
    "snet-external" = {
      subnet_id                 = azurerm_subnet.subnet["snet-external"].id
      network_security_group_id = azurerm_network_security_group.network_security_group["nsg-security"].id
    }
    "snet-internal" = {
      subnet_id                 = azurerm_subnet.subnet["snet-internal"].id
      network_security_group_id = azurerm_network_security_group.network_security_group["nsg-security"].id
    }
  }

  linux_virtual_machines = {
    "vm-fgt-1" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name                  = "vm-fgt-1"
      network_interface_ids = [for nic in ["nic-fortigate_1_ext", "nic-fortigate_1_int"] : azurerm_network_interface.network_interface[nic].id]

      size = local.vm_image["fortigate"].vm_size

      availability_set_id = local.availability_set ? azurerm_availability_set.availability_set["avail-1"].id : null
      zone                = local.availability_set ? null : local.vm-fgt-1_availability_zone

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

      identity_type                        = "SystemAssigned"
      boot_diagnostics_storage_account_uri = ""

      custom_data = templatefile(
        "${path.module}/fortios_config.conf", {
          host_name               = "vm-fgt-1"
          connect_to_fmg          = local.forti_manager_ip == "" && local.forti_manager_serial == "" ? "" : "true"
          forti_manager_ip        = local.forti_manager_ip
          forti_manager_serial    = local.forti_manager_serial
          license_type            = local.fortigate_license_type
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
        }
      )
    }
    "vm-fgt-2" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name                  = "vm-fgt-2"
      network_interface_ids = [for nic in ["nic-fortigate_2_ext", "nic-fortigate_2_int"] : azurerm_network_interface.network_interface[nic].id]

      size = local.vm_image["fortigate"].vm_size

      availability_set_id = local.availability_set ? azurerm_availability_set.availability_set["avail-1"].id : null
      zone                = local.availability_set ? null : local.vm-fgt-2_availability_zone

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

      identity_type                        = "SystemAssigned"
      boot_diagnostics_storage_account_uri = ""

      custom_data = templatefile(
        "${path.module}/fortios_config.conf", {
          host_name               = "vm-fgt-2"
          connect_to_fmg          = local.forti_manager_ip == "" && local.forti_manager_serial == "" ? "" : "true"
          forti_manager_ip        = local.forti_manager_ip
          forti_manager_serial    = local.forti_manager_serial
          license_type            = local.fortigate_license_type
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
      zone                 = local.availability_set ? null : local.vm-fgt-1_availability_zone
    }
    "data_disk-fgt-2" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name                 = "data_disk-fgt-2"
      storage_account_type = "Premium_LRS"
      create_option        = "Empty"
      disk_size_gb         = 30
      zone                 = local.availability_set ? null : local.vm-fgt-2_availability_zone
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