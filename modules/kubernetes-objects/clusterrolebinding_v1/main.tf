resource "kubernetes_cluster_role_binding_v1" "this" {
  for_each = { for crb in var.cluster_role_bindings : crb.name => crb }

  metadata {
    name = each.value.name
  }
  role_ref {
    api_group = each.value.role_ref.api_group
    kind      = each.value.role_ref.kind
    name      = each.value.role_ref.name
  }
  dynamic "subject" {
    for_each = { for k, v in each.value.subjects : k => v }
    content {
      kind      = subject.value.kind
      name      = subject.value.name
      api_group = subject.value.api_group
      namespace = subject.value.namespace
    }
  }
}
