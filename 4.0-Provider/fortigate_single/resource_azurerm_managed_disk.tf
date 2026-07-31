resource "azurerm_managed_disk" "managed_disk" {
  for_each = local.managed_disks

  resource_group_name = each.value.resource_group_name
  location            = each.value.location

  name                 = each.value.name
  storage_account_type = each.value.storage_account_type
  create_option        = each.value.create_option
  disk_size_gb         = each.value.disk_size_gb
  zone                 = each.value.zone
}

output "managed_disks" {
  value = var.enable_output ? azurerm_managed_disk.managed_disk[*] : null
}
