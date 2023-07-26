resource "azurerm_virtual_machine" "virtual_machine" {
  for_each = local.virtual_machines

  resource_group_name = each.value.resource_group_name
  location            = each.value.location

  name    = each.value.name
  vm_size = each.value.vm_size

  availability_set_id = each.value.availability_set_id
  zones               = each.value.zones

  network_interface_ids        = each.value.network_interface_ids
  primary_network_interface_id = each.value.primary_network_interface_id

  delete_os_disk_on_termination    = each.value.delete_os_disk_on_termination
  delete_data_disks_on_termination = each.value.delete_data_disks_on_termination

  identity {
    type = each.value.identity_identity
  }

  storage_image_reference {
    publisher = each.value.storage_image_reference_publisher
    offer     = each.value.storage_image_reference_offer
    sku       = each.value.storage_image_reference_sku
    version   = each.value.storage_image_reference_version
  }

  plan {
    publisher = each.value.plan_publisher
    product   = each.value.plan_product
    name      = each.value.plan_name
  }

  storage_os_disk {
    name              = each.value.storage_os_disk_name
    caching           = each.value.storage_os_disk_caching
    create_option     = each.value.storage_os_disk_create_option
    managed_disk_type = each.value.storage_os_disk_managed_disk_type
  }

  dynamic "storage_data_disk" {
    for_each = each.value.storage_data_disks
    content {
      name              = storage_data_disk.value.name
      managed_disk_type = storage_data_disk.value.managed_disk_type
      create_option     = storage_data_disk.value.create_option
      disk_size_gb      = storage_data_disk.value.disk_size_gb
      lun               = storage_data_disk.value.lun
    }
  }

  os_profile {
    computer_name  = each.value.name
    admin_username = each.value.os_profile_admin_username
    admin_password = each.value.os_profile_admin_password
    custom_data    = each.value.os_profile_custom_data
  }

  os_profile_linux_config {
    disable_password_authentication = each.value.os_profile_linux_config_disable_password_authentication
  }

  boot_diagnostics {
    enabled     = each.value.boot_diagnostics_enabled
    storage_uri = each.value.boot_diagnostics_storage_uri
  }
}

output "virtual_machines" {
  value     = var.enable_output ? azurerm_virtual_machine.virtual_machine[*] : null
  sensitive = true
}