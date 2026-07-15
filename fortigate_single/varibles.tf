variable "username" {
  description = "username"
}

variable "password" {
  description = "password"
  sensitive   = true
}

variable "enable_output" {
  description = "Enable/Disable output"
  default     = true
}