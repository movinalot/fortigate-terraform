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

variable "fortigate_1_license_token" {
  description = "FortiGate 1 FortiFlex license token"
  default     = ""
}

variable "fortigate_2_license_token" {
  description = "FortiGate 2 FortiFlex license token"
  default     = ""
}

variable "fortigate_1_license_file" {
  description = "Path to the FortiGate 1 license file"
  default     = ""
}

variable "fortigate_2_license_file" {
  description = "Path to the FortiGate 2 license file"
  default     = ""
}

variable "enable_output" {
  description = "Enable/Disable output"
  default     = true
}
