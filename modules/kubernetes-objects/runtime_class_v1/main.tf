resource "kubernetes_runtime_class_v1" "this" {
  for_each = { for rc in var.runtime_classes : rc.name => rc }

  metadata {
    name        = each.value.name
    labels      = each.value.labels
    annotations = each.value.annotations
  }

  handler = each.value.handler
}
