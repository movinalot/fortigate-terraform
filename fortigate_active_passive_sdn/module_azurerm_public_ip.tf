locals {
  public_ips = {
    (var.public_ips["public_ip_01"].name) = {
      name = var.public_ips["public_ip_01"].name
    }
    (var.public_ips["public_ip_02"].name) = {
      name = var.public_ips["public_ip_02"].name
    }
    (var.public_ips["public_ip_03"].name) = {
      name = var.public_ips["public_ip_03"].name
    }
  }
  allocation_method = "Static"
  sku               = "Standard"

}

module "module_azurerm_public_ip" {
  for_each = local.public_ips

  source = "../azure/rm/azurerm_public_ip"

  resource_group_name = module.module_azurerm_resource_group.resource_group.name
  location            = module.module_azurerm_resource_group.resource_group.location
  name                = each.value.name
  allocation_method   = local.allocation_method
  sku                 = local.sku

}

output "public_ips" {
  value = module.module_azurerm_public_ip[*]
}