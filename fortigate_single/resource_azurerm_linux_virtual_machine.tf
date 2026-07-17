resource "azurerm_linux_virtual_machine" "linux_virtual_machine" {
  for_each = local.linux_virtual_machines

  resource_group_name = each.value.resource_group_name
  location            = each.value.location

  name                  = each.value.name
  network_interface_ids = each.value.network_interface_ids

  size = each.value.size

  admin_username = each.value.username
  admin_password = each.value.password

  disable_password_authentication = each.value.disable_password_authentication

  source_image_reference {
    publisher = each.value.source_image_reference_publisher
    offer     = each.value.source_image_reference_offer
    sku       = each.value.source_image_reference_sku
    version   = each.value.source_image_reference_version
  }

  dynamic "plan" {
    for_each = each.value.plan
    content {
      publisher = plan.value.publisher
      product   = plan.value.product
      name      = plan.value.name
    }
  }

  os_disk {
    name                 = each.value.os_disk_name
    caching              = each.value.os_disk_caching
    storage_account_type = each.value.os_disk_storage_account_type
  }

  custom_data = base64encode(each.value.custom_data)

  identity {
    type = each.value.identity_type
  }

  boot_diagnostics {
    storage_account_uri = each.value.boot_diagnostics_storage_account_uri
  }
}

output "linux_virtual_machines" {
  value = var.enable_output ? azurerm_linux_virtual_machine.linux_virtual_machine[*] : null
  sensitive = true
}
