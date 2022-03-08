locals {
  public_ips = {
    "pip-fgt-v-lb-fe" = { name = "pip-fgt-v-lb-fe", allocation_method = "Static", sku = "Standard" }
    "pip-fgt-a-ipsec" = { name = "pip-fgt-a-ipsec", allocation_method = "Static", sku = "Standard" }
    "pip-fgt-b-ipsec" = { name = "pip-fgt-b-ipsec", allocation_method = "Static", sku = "Standard" }
  }
}

module "module_azurerm_public_ip" {
  for_each = local.public_ips

  source = "../azure/rm/azurerm_public_ip"

  resource_group_name = module.module_azurerm_resource_group.resource_group.name
  location            = module.module_azurerm_resource_group.resource_group.location
  name                = each.value.name
  allocation_method   = each.value.allocation_method
  sku                 = each.value.sku

}

output "public_ips" {
  value = module.module_azurerm_public_ip[*]
}