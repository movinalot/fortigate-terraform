output "ResourceGroup_Location" {
  value = format("%s / %s", local.resource_group_name, local.resource_group_location)
}

output "FortiGate_Public_IP" {
  value = format("https://%s", module.module_azurerm_public_ip["pip-fgt"].public_ip.ip_address)
}

output "FortiGate_1_Public_IP_MGMT" {
  value = format("https://%s", module.module_azurerm_public_ip["pip-fgt_1_mgmt"].public_ip.ip_address)
}

output "FortiGate_2_Public_IP_MGMT" {
  value = format("https://%s", module.module_azurerm_public_ip["pip-fgt_2_mgmt"].public_ip.ip_address)
}

output "credentials" {
  value     = format("username: %s / password: %s", local.username, local.password)
  sensitive = true
}
