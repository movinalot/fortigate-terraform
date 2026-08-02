resource "azurerm_subnet" "subnet" {
  for_each = local.subnets

  resource_group_name = each.value.resource_group_name

  name                 = each.value.name
  virtual_network_name = each.value.virtual_network_name
  address_prefixes     = each.value.address_prefixes
}

output "subnets" {
  value = var.enable_output ? azurerm_subnet.subnet[*] : null
}
