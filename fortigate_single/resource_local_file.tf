resource "local_file" "file" {
  for_each = local.linux_virtual_machines

  filename = format("fortios_%s.cfg", each.value.name)
  content  = local.linux_virtual_machines[each.key].custom_data
}
