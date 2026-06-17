resource "kubernetes_config_map" "this" {
  for_each = { for cm in var.config_maps : cm.name => cm }
  metadata {
    name      = each.value.name
    namespace = each.value.namespace
  }

  data = each.value.data
}