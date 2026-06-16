resource "kubernetes_secret" "this" {
  for_each = { for s in var.secrets : s.name => s }

  metadata {
    name      = each.value.name
    namespace = each.value.namespace
  }

  type = each.value.type
  data = each.value.data
}
