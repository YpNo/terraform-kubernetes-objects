resource "kubernetes_role_binding_v1" "this" {
  for_each = { for rb in var.role_bindings : rb.name => rb }

  metadata {
    name      = each.value.name
    namespace = each.value.namespace
  }
  role_ref {
    api_group = each.value.role_ref.api_group
    kind      = each.value.role_ref.kind
    name      = each.value.role_ref.name
  }
  subject {
    kind      = each.value.subject.kind
    name      = each.value.subject.name
    api_group = each.value.subject.api_group
    namespace = each.value.subject.namespace
  }
}
