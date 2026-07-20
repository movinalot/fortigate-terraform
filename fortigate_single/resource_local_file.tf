resource "local_file" "file" {
  for_each = local.linux_virtual_machines

  filename = format("fortios_%s.cfg", each.value.name)
  content  = local.linux_virtual_machines[each.key].custom_data
}

output "local_files" {
  value     = var.enable_output ? local_file.file[*] : null
  sensitive = true
}
