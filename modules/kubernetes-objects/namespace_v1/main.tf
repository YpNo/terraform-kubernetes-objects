resource "kubernetes_namespace_v1" "this" {
  for_each = { for ns in var.namespaces : ns.name => ns }

  metadata {
    annotations = each.value.annotations

    labels = merge(each.value.labels, {
      managed-by = "terraform"
    })

    name = each.value.name
  }
}
