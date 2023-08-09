resource "local_file" "file" {
  for_each = local.virtual_machines

  filename = format("fortios_%s.cfg", each.value.name)
  content  = local.virtual_machines[each.key].os_profile_custom_data
}
