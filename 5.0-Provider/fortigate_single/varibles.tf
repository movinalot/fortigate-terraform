variable "resource_group_name" {
  description = "Resource group name"
}

variable "tags" {
  description = "Tags to be applied to the resources"
  type        = map(string)
}

variable "username" {
  description = "admin username for the FortiGate VM"
}

variable "password" {
  description = "admin password for the FortiGate VM"
  sensitive   = true
}

variable "fortigate_license_token" {
  description = "FortiGate FortiFlex license token"
  default     = ""
}

variable "fortigate_license_file" {
  description = "Path to the FortiGate license file"
  default     = ""
}

variable "enable_output" {
  description = "Enable/Disable output"
  default     = true
}