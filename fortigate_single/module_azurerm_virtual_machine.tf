locals {
  virtual_machines = {
    "vm-fgt" = {
      name              = "vm-fgt"
      config_template   = "fortios_config.conf"
      identity_identity = "SystemAssigned"

      #availability_set_id = module.module_azurerm_availability_set["as_1"].subnet.id
      availability_set_id = null

      delete_os_disk_on_termination    = true
      delete_data_disks_on_termination = true

      network_interface_ids        = [for nic in ["nic-fortigate_1", "nic-fortigate_2"] : module.module_azurerm_network_interface[nic].network_interface.id]
      primary_network_interface_id = module.module_azurerm_network_interface["nic-fortigate_1"].network_interface.id
      public_ip_address            = module.module_azurerm_public_ip["pip-fgt"].public_ip.ip_address

      vm_size = "Standard_F4s"

      connect_to_fmg = ""
      license_type   = "flexvm"
      license_file   = ""
      serial_number  = ""
      license_token  = "FE5614862677446686E4"


      storage_image_reference_publisher = "fortinet"
      storage_image_reference_offer     = "fortinet_fortigate-vm_v5"
      storage_image_reference_sku       = "fortinet_fg-vm"
      storage_image_reference_version   = "7.0.3"

      plan_name                 = "fortinet_fg-vm"
      plan_publisher            = "fortinet"
      plan_product              = "fortinet_fortigate-vm_v5"
      os_profile_admin_username = "azureuser"
      os_profile_admin_password = "Password123!!"

      os_profile_linux_config_disable_password_authentication = false

      boot_diagnostics_enabled     = true
      boot_diagnostics_storage_uri = module.module_azurerm_storage_account["st-diag"].storage_account.primary_blob_endpoint

      storage_os_disk_name              = "osDisk"
      storage_os_disk_caching           = "ReadWrite"
      storage_os_disk_managed_disk_type = "Premium_LRS"
      storage_os_disk_create_option     = "FromImage"

      storage_data_disk_name              = "fgtvmdatadisk"
      storage_data_disk_managed_disk_type = "Premium_LRS"
      storage_data_disk_create_option     = "Empty"
      storage_data_disk_disk_size_gb      = "30"
      storage_data_disk_lun               = "0"

      #zones = ["1"]
      zones = null
    }
  }
}

module "module_azurerm_virtual_machine" {
  for_each = local.virtual_machines

  source = "../azure/rm/azurerm_virtual_machine"

  resource_group_name = module.module_azurerm_resource_group.resource_group.name
  location            = module.module_azurerm_resource_group.resource_group.location
  name                = each.value.name

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
  os_profile_custom_data    = data.template_file.config_files[each.value.name].rendered


  storage_os_disk_name                = each.value.storage_os_disk_name
  storage_os_disk_caching             = each.value.storage_os_disk_caching
  storage_os_disk_managed_disk_type   = each.value.storage_os_disk_managed_disk_type
  storage_os_disk_create_option       = each.value.storage_os_disk_create_option
  storage_data_disk_name              = each.value.storage_data_disk_name
  storage_data_disk_managed_disk_type = each.value.storage_data_disk_managed_disk_type
  storage_data_disk_create_option     = each.value.storage_data_disk_create_option
  storage_data_disk_disk_size_gb      = each.value.storage_data_disk_disk_size_gb
  storage_data_disk_lun               = each.value.storage_data_disk_lun

  os_profile_linux_config_disable_password_authentication = each.value.os_profile_linux_config_disable_password_authentication

  boot_diagnostics_enabled     = each.value.boot_diagnostics_enabled
  boot_diagnostics_storage_uri = each.value.boot_diagnostics_storage_uri

  zones = each.value.zones
}

resource "null_resource" "flexvm_create_reactivate" {
  provisioner "local-exec" {
    when    = create
    command = "./flexvm_ops.sh ${var.flexvm_api_user} ${var.flexvm_api_pass} ${var.flexvm_program} ${var.flexvm_config} ${var.serial_number} ${var.flexvm_op}"
  }
}

#resource "null_resource" "flexvm_stop" {
#    provisioner "local-exec" {
#    when    = destroy
#    command = "./flexvm_ops.sh ${var.flexvm_api_user} ${var.flexvm_api_pass} ${var.flexvm_program} ${var.flexvm_config} ${var.serial_number} ${var.flexvm_op}"
#  }
#}

resource "random_string" "random_apikey" {

  for_each = local.virtual_machines

  length  = 30
  special = false
}

data "template_file" "config_files" {

  for_each = local.virtual_machines

  template = file(each.value.config_template)
  vars = {
    host_name            = each.value.name
    license_type         = each.value.license_type
    connect_to_fmg       = each.value.connect_to_fmg
    forti_manager_ip     = var.forti_manager_ip
    forti_manager_serial = var.forti_manager_serial
    license_file         = each.value.license_file
    serial_number        = each.value.serial_number
    license_token        = each.value.license_token
    api_key              = random_string.random_apikey[each.value.name].id
  }
}

data "template_file" "files" {

  for_each = local.virtual_machines

  template = file("${path.module}/fortios_access.conf")
  vars = {
    fortios_access_hostname = each.value.public_ip_address
    fortios_access_token    = random_string.random_apikey[each.value.name].id
    fortios_insecure        = "true"
  }
}

resource "local_file" "files" {

  for_each = local.virtual_machines

  filename = "${path.module}/fortios_access_${each.value.name}.sh"
  content  = data.template_file.files[each.value.name].rendered
}

output "virtual_machines" {
  value     = module.module_azurerm_virtual_machine[*]
  sensitive = true
}
