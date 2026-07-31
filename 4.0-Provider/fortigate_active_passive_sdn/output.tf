output "ResourceGroup_Location" {
  value = format("%s / %s", local.resource_group_name, local.resource_group_location)
}

output "FortiGate_Public_IP" {
  value = format("https://%s", azurerm_public_ip.public_ip["pip-fgt"].ip_address)
}

output "FortiGate_MGMT_IPs" {
  value = format("FortiGate - 1: https://%s:%s\nFortiGate - 2: https://%s:%s\n", azurerm_public_ip.public_ip["pip-fgt_1_mgmt"].ip_address, local.admin-sport, azurerm_public_ip.public_ip["pip-fgt_2_mgmt"].ip_address, local.admin-sport)
}

output "FortiGate_Credentials" {
  value     = format("username: %s / password: %s", local.username, local.password)
  sensitive = true
}
