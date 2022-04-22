resource "random_id" "id" {
  for_each = local.random_ids

  keepers = {
    resource_group_name = each.value.keepers_resource_group_name
  }

  byte_length = each.value.byte_length
}