resource "azurerm_virtual_machine_data_disk_attachment" "virtual_machine_data_disk_attachment" {
  for_each = local.virtual_machine_data_disk_attachments

  managed_disk_id    = each.value.managed_disk_id
  virtual_machine_id = each.value.virtual_machine_id
  lun                = each.value.lun
  caching            = each.value.caching
}