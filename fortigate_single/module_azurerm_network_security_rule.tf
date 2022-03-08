locals {
  network_security_rules = {
    "nsr-public-ingress" = {
      name                        = "nsr-public-ingress"
      priority                    = 1001
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
      network_security_group_name = module.module_azurerm_network_security_group["nsg-public"].network_security_group.name
    },
    "nsr-public-egress" = {
      name                        = "nsr-public-egress"
      priority                    = 1002
      direction                   = "Outbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
      network_security_group_name = module.module_azurerm_network_security_group["nsg-public"].network_security_group.name
    },
    "nsr-private-ingress" = {
      name                        = "nsr-private-ingress"
      priority                    = 1003
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
      network_security_group_name = module.module_azurerm_network_security_group["nsg-private"].network_security_group.name
    },
    "nsr-private-egress" = {
      name                        = "nsr-private-egress"
      priority                    = 1004
      direction                   = "Outbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
      network_security_group_name = module.module_azurerm_network_security_group["nsg-private"].network_security_group.name
    }
  }
}

module "module_azurerm_network_security_rule" {
  for_each = local.network_security_rules

  source = "../azure/rm/azurerm_network_security_rule"

  resource_group_name         = module.module_azurerm_resource_group.resource_group.name
  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
  network_security_group_name = each.value.network_security_group_name
}

output "network_security_rules" {
  value = module.module_azurerm_network_security_rule[*]
}
