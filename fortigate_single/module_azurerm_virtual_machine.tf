module "module_azurerm_virtual_machine" {
  for_each = local.virtual_machines

  source = "../azure/rm/azurerm_virtual_machine"

  resource_group_name = each.value.resource_group_name
  location            = each.value.location

  name = each.value.name

  availability_set_id = each.value.availability_set_id

  network_interface_ids        = each.value.network_interface_ids
  primary_network_interface_id = each.value.primary_network_interface_id

  vm_size = each.value.vm_size

  delete_os_disk_on_termination    = each.value.delete_os_disk_on_termination
  delete_data_disks_on_termination = each.value.delete_data_disks_on_termination

  identity_identity = each.value.identity_identity

  storage_image_reference_publisher = each.value.storage_image_reference_publisher
  storage_image_reference_offer     = each.value.storage_image_reference_offer
  storage_image_reference_sku       = each.value.storage_image_reference_sku
  storage_image_reference_version   = each.value.storage_image_reference_version

  plan_name      = each.value.plan_name
  plan_publisher = each.value.plan_publisher
  plan_product   = each.value.plan_product

  os_profile_computer_name  = each.value.name
  os_profile_admin_username = each.value.os_profile_admin_username
  os_profile_admin_password = each.value.os_profile_admin_password
  os_profile_custom_data    = each.value.config_data


  storage_os_disk_name              = each.value.storage_os_disk_name
  storage_os_disk_caching           = each.value.storage_os_disk_caching
  storage_os_disk_managed_disk_type = each.value.storage_os_disk_managed_disk_type
  storage_os_disk_create_option     = each.value.storage_os_disk_create_option

  storage_data_disks = each.value.storage_data_disks

  os_profile_linux_config_disable_password_authentication = each.value.os_profile_linux_config_disable_password_authentication

  boot_diagnostics_enabled     = each.value.boot_diagnostics_enabled
  boot_diagnostics_storage_uri = each.value.boot_diagnostics_storage_uri

  zones = each.value.zones

}

output "virtual_machines" {
  value     = var.enable_module_output ? module.module_azurerm_virtual_machine[*] : null
  sensitive = true
}