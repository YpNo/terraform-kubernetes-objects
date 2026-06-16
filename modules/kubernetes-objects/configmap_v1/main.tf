resource "kubernetes_config_map_v1" "this" {
  for_each = { for cm in var.config_maps : cm.name => cm }
  metadata {
    name      = each.value.name
    namespace = each.value.namespace
  }

  data = each.value.data
}