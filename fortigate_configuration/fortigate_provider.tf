terraform {
  required_providers {
    fortios = {
      source = "fortinetdev/fortios"
    }
  }
  required_version = ">= 1.0.0"
}

provider "fortios" {
}
