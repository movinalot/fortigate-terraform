variable "resource_group_name" {
  description = "Resource Group name"
}
variable "resource_group_location" {
  description = "Resource Group location"
}

variable "virtual_network_name" {
  description = "Virtual Network Name"
  type        = string
  default     = ""
}

variable "virtual_network_address_space" {
  description = "Virtual Network Name"
  type        = string
  default     = ""
}

variable "subnets" {
  description = "Virtual Network Subnets"
  type        = map(any)
  default = {
    name               = "",
    cidrsubnet_newbits = 0,
    cidrsubnet_netnum  = 0
  }
}

variable "public_ips" {
  description = "Public IPs"
  type        = map(any)
  default = {
    name = ""
  }
}

variable "route_tables" {
  description = "Route Tables"
  type        = map(any)
  default = {
    name = ""
  }
}

variable "routes" {
  description = "Routes"
  type        = map(any)
  default = {
    name                   = ""
    address_prefix         = ""
    next_hop_in_ip_address = ""
    next_hop_type          = ""
    route_table_name       = ""
  }
}

variable "image_publisher" {
  description = "Image Publisher"
  type        = string
  default     = "fortinet"
}

variable "image_offer" {
  description = "Image Offer"
  type        = string
  default     = ""
  # byol and flexvm image - fortinet_fortigate-vm_v5
  # payg image - fortinet_fg-vm_payg_20190624
}

variable "availability_set_name" {
  description = "Availability Set Name"
  type        = string
  default     = ""
  # 
  # depends on availability_option selection of
  #
  #  - availability_set
  #  - availability_zone
  #
  # An Availability Set will be used if
  #  - availability_option is set to availability_set
  #  - availability_option is set to an invalid choice
  #  - availability_option is set to availability_zone but the region does not support Availability Zones

}
