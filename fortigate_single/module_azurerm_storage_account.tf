locals {
  storage_accounts = {
    "st-diag" = {
      name                     = "stdiag"
      account_replication_type = "LRS"
      account_tier             = "Standard"
    }
  }
}

module "module_azurerm_storage_account" {
  for_each = local.storage_accounts

  source = "../azure/rm/azurerm_storage_account"

  resource_group_name      = module.module_azurerm_resource_group.resource_group.name
  location                 = module.module_azurerm_resource_group.resource_group.location
  name                     = format("%s%s", each.value.name, "${random_id.random_id.hex}")
  account_replication_type = each.value.account_replication_type
  account_tier             = each.value.account_tier
}

resource "random_id" "random_id" {
  keepers = {
    resource_group_name = module.module_azurerm_resource_group.resource_group.name
  }

  byte_length = 8
}

output "storage_accounts" {
  value     = module.module_azurerm_storage_account[*]
  sensitive = true
}
