resource "kubernetes_secret_v1" "this" {
  for_each = { for s in var.secrets : s.name => s }

  metadata {
    name      = each.value.name
    namespace = each.value.namespace
  }

  type = each.value.type
  data = each.value.data
}
