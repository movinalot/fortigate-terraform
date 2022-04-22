module "module_azurerm_storage_account" {
  for_each = local.storage_accounts

  source = "../azure/rm/azurerm_storage_account"

  resource_group_name = each.value.resource_group_name
  location            = each.value.location

  name                     = each.value.name
  account_replication_type = each.value.account_replication_type
  account_tier             = each.value.account_tier
}

output "storage_accounts" {
  value     = var.enable_module_output ? module.module_azurerm_storage_account[*] : null
  sensitive = true
}
