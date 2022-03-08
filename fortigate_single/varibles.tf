variable "resource_group_name" {
  description = "Resource Group name"
  default     = ""
}

variable "resource_group_location" {
  description = "Resource Group location"
  default     = ""
}

variable "forti_manager_ip" {
  default = ""
}

variable "forti_manager_serial" {
  default = ""
}

variable "flexvm_config" {
  default = ""
}

variable "flexvm_program" {
  default = ""
}

variable "flexvm_api_user" {
  default = ""
}

variable "flexvm_api_pass" {
  default = ""
}

variable "flexvm_op" {
  default = ""
}

variable "serial_number" {}