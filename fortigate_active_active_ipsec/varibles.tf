variable "resource_group_name" {
  description = "Resource Group name"
}
variable "resource_group_location" {
  description = "Resource Group location"
}


variable "forti_manager_ip" {
  description = "FortiManager IP"
  type        = string
  default     = ""
}
variable "forti_manager_serial" {
  description = "FortiManager Serial Number"
  type        = string
  default     = ""
}
