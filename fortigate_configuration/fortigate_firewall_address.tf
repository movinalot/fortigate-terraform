resource "fortios_firewall_address" "address" {
  name       = "testaddr"
  subnet     = "10.10.10.0/24"
  type       = "ipmask"
  visibility = "enable"
}