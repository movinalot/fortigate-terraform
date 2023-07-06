resource "azurerm_network_interface" "network_interface" {
  for_each = local.network_interfaces

  resource_group_name = each.value.resource_group_name
  location            = each.value.location

  name                          = each.value.name
  enable_ip_forwarding          = each.value.enable_ip_forwarding
  enable_accelerated_networking = each.value.enable_accelerated_networking

  dynamic "ip_configuration" {

    for_each = each.value.ip_configurations
    content {
      name                          = ip_configuration.value.name
      primary                       = lookup(ip_configuration.value, "primary", false)
      subnet_id                     = ip_configuration.value.subnet_id
      private_ip_address_allocation = ip_configuration.value.private_ip_address_allocation
      private_ip_address            = ip_configuration.value.private_ip_address
      public_ip_address_id          = ip_configuration.value.public_ip_address_id
    }
  }
}

output "network_interfaces" {
  value = var.enable_output ? azurerm_network_interface.network_interface[*] : null
}
