locals {

  username = "azureuser"
  password = "Password123!!"

  resource_group_name     = "rg-fortigate_ap_elb_ilb"
  resource_group_location = "eastus2"

  virtual_network_name = "vnet-security"

  # FortiGate Licese files are expected to be
  # in the same folder as this file, when using byol

  fortigate_1_license_file = ""
  fortigate_2_license_file = ""

  fortigate_1_license_token = ""
  fortigate_2_license_token = ""

  connect_to_fmg       = ""
  forti_manager_ip     = ""
  forti_manager_serial = ""

  license_type = "payg" # can be byol, flex, or payg, make sure the license is correct for the sku

  vm_image = {
    "fortigate" = {
      publisher = "fortinet"
      offer     = "fortinet_fortigate-vm_v5"
      sku       = local.license_type == "payg" ? "fortinet_fg-vm_payg_2022" : "fortinet_fg-vm" # byol and flex use: fortinet_fg-vm | payg use: fortinet_fg-vm_payg_2022
      vm_size   = "Standard_D8s_v4"
      version   = "7.2.5" # an be a verrsion number as well, e.g. 6.4.9, 7.0.6, 7.2.5, 7.4.0
    }
  }

  resource_groups = {
    (local.resource_group_name) = {
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
      address_prefixes     = [cidrsubnet(azurerm_virtual_network.virtual_network[local.virtual_network_name].address_space[0], 4, 0)]
    }
    "snet-internal" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name

      name                 = "snet-internal"
      virtual_network_name = azurerm_virtual_network.virtual_network[local.virtual_network_name].name
      address_prefixes     = [cidrsubnet(azurerm_virtual_network.virtual_network[local.virtual_network_name].address_space[0], 4, 1)]
    }
    "snet-hasync" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name

      name                 = "snet-hasync"
      virtual_network_name = azurerm_virtual_network.virtual_network[local.virtual_network_name].name
      address_prefixes     = [cidrsubnet(azurerm_virtual_network.virtual_network[local.virtual_network_name].address_space[0], 4, 2)]
    }
    "snet-mgmt" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name

      name                 = "snet-mgmt"
      virtual_network_name = azurerm_virtual_network.virtual_network[local.virtual_network_name].name
      address_prefixes     = [cidrsubnet(azurerm_virtual_network.virtual_network[local.virtual_network_name].address_space[0], 4, 3)]
    }
    "snet-protected" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name

      name                 = "snet-protected"
      virtual_network_name = azurerm_virtual_network.virtual_network[local.virtual_network_name].name
      address_prefixes     = [cidrsubnet(azurerm_virtual_network.virtual_network[local.virtual_network_name].address_space[0], 2, 1)]
    }
  }

  network_interfaces = {
    "nic-fortigate_1_1" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name                          = "nic-fortigate_1_1"
      enable_ip_forwarding          = true
      enable_accelerated_networking = true
      ip_configurations = [
        {
          name                          = "ipconfig1"
          primary                       = true
          subnet_id                     = azurerm_subnet.subnet["snet-external"].id
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(azurerm_subnet.subnet["snet-external"].address_prefixes[0], 4)
          public_ip_address_id          = null
        }
      ]
    }
    "nic-fortigate_1_2" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name                          = "nic-fortigate_1_2"
      enable_ip_forwarding          = true
      enable_accelerated_networking = true
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
    "nic-fortigate_1_3" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name                          = "nic-fortigate_1_3"
      enable_ip_forwarding          = true
      enable_accelerated_networking = true
      ip_configurations = [
        {
          name                          = "ipconfig1"
          primary                       = true
          subnet_id                     = azurerm_subnet.subnet["snet-hasync"].id
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(azurerm_subnet.subnet["snet-hasync"].address_prefixes[0], 4)
          public_ip_address_id          = null
        }
      ]
    }
    "nic-fortigate_1_4" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name                          = "nic-fortigate_1_4"
      enable_ip_forwarding          = true
      enable_accelerated_networking = true
      ip_configurations = [
        {
          name                          = "ipconfig1"
          primary                       = true
          subnet_id                     = azurerm_subnet.subnet["snet-mgmt"].id
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(azurerm_subnet.subnet["snet-mgmt"].address_prefixes[0], 4)
          public_ip_address_id          = null
        }
      ]
    }
    "nic-fortigate_2_1" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name                          = "nic-fortigate_2_1"
      enable_ip_forwarding          = true
      enable_accelerated_networking = true
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
    "nic-fortigate_2_2" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name                          = "nic-fortigate_2_2"
      enable_ip_forwarding          = true
      enable_accelerated_networking = true
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
    "nic-fortigate_2_3" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name                          = "nic-fortigate_2_3"
      enable_ip_forwarding          = true
      enable_accelerated_networking = true
      ip_configurations = [
        {
          name                          = "ipconfig1"
          primary                       = true
          subnet_id                     = azurerm_subnet.subnet["snet-hasync"].id
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(azurerm_subnet.subnet["snet-hasync"].address_prefixes[0], 5)
          public_ip_address_id          = null
        }
      ]
    }
    "nic-fortigate_2_4" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name                          = "nic-fortigate_2_4"
      enable_ip_forwarding          = true
      enable_accelerated_networking = true
      ip_configurations = [
        {
          name                          = "ipconfig1"
          primary                       = true
          subnet_id                     = azurerm_subnet.subnet["snet-mgmt"].id
          private_ip_address_allocation = "Static"
          private_ip_address            = cidrhost(azurerm_subnet.subnet["snet-mgmt"].address_prefixes[0], 5)
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
          public_ip_address_id = azurerm_public_ip.public_ip["pip-fgt"].id
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
    "nic-fortigate_1_1" = {
      network_interface_id    = azurerm_network_interface.network_interface["nic-fortigate_1_1"].id
      ip_configuration_name   = "ipconfig1"
      backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend_address_pool["lbe-external_pool"].id
    }
    "nic-fortigate_2_1" = {
      network_interface_id    = azurerm_network_interface.network_interface["nic-fortigate_2_1"].id
      ip_configuration_name   = "ipconfig1"
      backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend_address_pool["lbe-external_pool"].id
    }
    "nic-fortigate_1_2" = {
      network_interface_id    = azurerm_network_interface.network_interface["nic-fortigate_1_2"].id
      ip_configuration_name   = "ipconfig1"
      backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend_address_pool["lbi-internal_pool"].id
    }
    "nic-fortigate_2_2" = {
      network_interface_id    = azurerm_network_interface.network_interface["nic-fortigate_2_2"].id
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
      name                           = "hub1_fgt2_https"
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
      network_interface_id  = azurerm_network_interface.network_interface["nic-fortigate_1_4"].id
      ip_configuration_name = "ipconfig1"
      nat_rule_id           = azurerm_lb_nat_rule.lb_nat_rule["fgt_1_https"].id
    }
    "fgt_2_https" = {
      network_interface_id  = azurerm_network_interface.network_interface["nic-fortigate_2_4"].id
      ip_configuration_name = "ipconfig1"
      nat_rule_id           = azurerm_lb_nat_rule.lb_nat_rule["fgt_2_https"].id
    }
    "fgt_1_ssh" = {
      network_interface_id  = azurerm_network_interface.network_interface["nic-fortigate_1_4"].id
      ip_configuration_name = "ipconfig1"
      nat_rule_id           = azurerm_lb_nat_rule.lb_nat_rule["fgt_1_ssh"].id
    }
    "fgt_2_ssh" = {
      network_interface_id  = azurerm_network_interface.network_interface["nic-fortigate_2_4"].id
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

      name                   = "rt-default"
      address_prefix         = "0.0.0.0/0"
      next_hop_in_ip_address = cidrhost(azurerm_subnet.subnet["snet-internal"].address_prefixes[0], 6)
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
    "snet-hasync" = {
      subnet_id                 = azurerm_subnet.subnet["snet-hasync"].id
      network_security_group_id = azurerm_network_security_group.network_security_group["nsg-internal"].id
    }
    "snet-mgmt" = {
      subnet_id                 = azurerm_subnet.subnet["snet-mgmt"].id
      network_security_group_id = azurerm_network_security_group.network_security_group["nsg-internal"].id
    }
  }

  virtual_machines = {
    "vm_fgt_1" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name    = "vm-fgt-1"
      vm_size = local.vm_image["fortigate"].vm_size

      network_interface_ids        = [for nic in ["nic-fortigate_1_1", "nic-fortigate_1_2", "nic-fortigate_1_3", "nic-fortigate_1_4"] : azurerm_network_interface.network_interface[nic].id]
      primary_network_interface_id = azurerm_network_interface.network_interface["nic-fortigate_1_1"].id

      delete_os_disk_on_termination    = true
      delete_data_disks_on_termination = true

      identity_identity = "SystemAssigned"

      # availability_set_id or zones can be set but not both, both can be null
      availability_set_id = local.availability_set ? azurerm_availability_set.availability_set["avail-1"].id : null
      zones               = local.availability_set ? null : ["1"]

      storage_image_reference_publisher = local.vm_image["fortigate"].publisher
      storage_image_reference_offer     = local.vm_image["fortigate"].offer
      storage_image_reference_sku       = local.vm_image["fortigate"].sku
      storage_image_reference_version   = local.vm_image["fortigate"].version

      plan_publisher = local.vm_image["fortigate"].publisher
      plan_product   = local.vm_image["fortigate"].offer
      plan_name      = local.vm_image["fortigate"].sku

      storage_os_disk_name              = "osdisk-fgt_1"
      storage_os_disk_caching           = "ReadWrite"
      storage_os_disk_managed_disk_type = "Premium_LRS"
      storage_os_disk_create_option     = "FromImage"

      storage_data_disks = [
        {
          name              = "disk-fgt_1"
          managed_disk_type = "Premium_LRS"
          create_option     = "Empty"
          disk_size_gb      = "30"
          lun               = "0"
        }
      ]

      os_profile_admin_username = local.username
      os_profile_admin_password = local.password
      os_profile_custom_data = templatefile(
        "./fortios_config.conf", {
          host_name               = "vm-fgt-1"
          connect_to_fmg          = local.connect_to_fmg
          license_type            = local.license_type
          forti_manager_ip        = local.forti_manager_ip
          forti_manager_serial    = local.forti_manager_serial
          license_file            = "${path.module}/${local.fortigate_1_license_file}"
          serial_number           = ""
          license_token           = local.fortigate_1_license_token
          api_key                 = random_string.string.id
          vnet_address_prefix     = azurerm_virtual_network.virtual_network["vnet-security"].address_space[0]
          external_subnet_gateway = cidrhost(azurerm_subnet.subnet["snet-external"].address_prefixes[0], 1)
          internal_subnet_gateway = cidrhost(azurerm_subnet.subnet["snet-internal"].address_prefixes[0], 1)
          port1_ip                = azurerm_network_interface.network_interface["nic-fortigate_1_1"].private_ip_address
          port1_netmask           = cidrnetmask(azurerm_subnet.subnet["snet-external"].address_prefixes[0])
          port2_ip                = azurerm_network_interface.network_interface["nic-fortigate_1_2"].private_ip_address
          port2_netmask           = cidrnetmask(azurerm_subnet.subnet["snet-internal"].address_prefixes[0])
          port3_ip                = azurerm_network_interface.network_interface["nic-fortigate_1_3"].private_ip_address
          port3_netmask           = cidrnetmask(azurerm_subnet.subnet["snet-hasync"].address_prefixes[0])
          port4_ip                = azurerm_network_interface.network_interface["nic-fortigate_1_4"].private_ip_address
          port4_netmask           = cidrnetmask(azurerm_subnet.subnet["snet-mgmt"].address_prefixes[0])
          mgmt_subnet_gateway     = cidrhost(azurerm_subnet.subnet["snet-mgmt"].address_prefixes[0], 1)
          ha_priority             = 255
          ha_peer                 = azurerm_network_interface.network_interface["nic-fortigate_2_3"].private_ip_address
        }
      )

      os_profile_linux_config_disable_password_authentication = false

      boot_diagnostics_enabled     = true
      boot_diagnostics_storage_uri = ""
    }

    "vm_fgt_2" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name    = "vm-fgt-2"
      vm_size = local.vm_image["fortigate"].vm_size

      network_interface_ids        = [for nic in ["nic-fortigate_2_1", "nic-fortigate_2_2", "nic-fortigate_2_3", "nic-fortigate_2_4"] : azurerm_network_interface.network_interface[nic].id]
      primary_network_interface_id = azurerm_network_interface.network_interface["nic-fortigate_2_1"].id

      delete_os_disk_on_termination    = true
      delete_data_disks_on_termination = true

      identity_identity = "SystemAssigned"

      # availability_set_id or zones can be set but not both, both can be null
      availability_set_id = local.availability_set ? azurerm_availability_set.availability_set["avail-1"].id : null
      zones               = local.availability_set ? null : ["2"]

      storage_image_reference_publisher = local.vm_image["fortigate"].publisher
      storage_image_reference_offer     = local.vm_image["fortigate"].offer
      storage_image_reference_sku       = local.vm_image["fortigate"].sku
      storage_image_reference_version   = local.vm_image["fortigate"].version

      plan_publisher = local.vm_image["fortigate"].publisher
      plan_product   = local.vm_image["fortigate"].offer
      plan_name      = local.vm_image["fortigate"].sku

      storage_os_disk_name              = "osdisk-fgt_2"
      storage_os_disk_caching           = "ReadWrite"
      storage_os_disk_managed_disk_type = "Premium_LRS"
      storage_os_disk_create_option     = "FromImage"

      storage_data_disks = [
        {
          name              = "disk-fgt_2"
          managed_disk_type = "Premium_LRS"
          create_option     = "Empty"
          disk_size_gb      = "30"
          lun               = "0"
        }
      ]

      os_profile_admin_username = local.username
      os_profile_admin_password = local.password
      os_profile_custom_data = templatefile(
        "./fortios_config.conf", {
          host_name               = "vm-fgt-2"
          connect_to_fmg          = local.connect_to_fmg
          license_type            = local.license_type
          forti_manager_ip        = local.forti_manager_ip
          forti_manager_serial    = local.forti_manager_serial
          license_file            = "${path.module}/${local.fortigate_2_license_file}"
          serial_number           = ""
          license_token           = local.fortigate_2_license_token
          api_key                 = random_string.string.id
          vnet_address_prefix     = azurerm_virtual_network.virtual_network["vnet-security"].address_space[0]
          external_subnet_gateway = cidrhost(azurerm_subnet.subnet["snet-external"].address_prefixes[0], 1)
          internal_subnet_gateway = cidrhost(azurerm_subnet.subnet["snet-internal"].address_prefixes[0], 1)
          port1_ip                = azurerm_network_interface.network_interface["nic-fortigate_2_1"].private_ip_address
          port1_netmask           = cidrnetmask(azurerm_subnet.subnet["snet-external"].address_prefixes[0])
          port2_ip                = azurerm_network_interface.network_interface["nic-fortigate_2_2"].private_ip_address
          port2_netmask           = cidrnetmask(azurerm_subnet.subnet["snet-internal"].address_prefixes[0])
          port3_ip                = azurerm_network_interface.network_interface["nic-fortigate_2_3"].private_ip_address
          port3_netmask           = cidrnetmask(azurerm_subnet.subnet["snet-hasync"].address_prefixes[0])
          port4_ip                = azurerm_network_interface.network_interface["nic-fortigate_2_4"].private_ip_address
          port4_netmask           = cidrnetmask(azurerm_subnet.subnet["snet-mgmt"].address_prefixes[0])
          mgmt_subnet_gateway     = cidrhost(azurerm_subnet.subnet["snet-mgmt"].address_prefixes[0], 1)
          ha_priority             = 1
          ha_peer                 = azurerm_network_interface.network_interface["nic-fortigate_1_3"].private_ip_address
        }
      )

      os_profile_linux_config_disable_password_authentication = false

      boot_diagnostics_enabled     = true
      boot_diagnostics_storage_uri = ""
    }
  }

  role_assignments = {
    "vm_fgt_1" = {
      scope                = azurerm_resource_group.resource_group[local.resource_group_name].id
      role_definition_name = "Contributor"
      principal_id         = azurerm_virtual_machine.virtual_machine["vm_fgt_1"].identity[0].principal_id
    }
    "vm_fgt_2" = {
      scope                = azurerm_resource_group.resource_group[local.resource_group_name].id
      role_definition_name = "Contributor"
      principal_id         = azurerm_virtual_machine.virtual_machine["vm_fgt_2"].identity[0].principal_id
    }
  }
}