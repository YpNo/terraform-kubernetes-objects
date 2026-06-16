resource "kubernetes_priority_class_v1" "this" {
  for_each = { for pc in var.priority_classes : pc.name => pc }

  metadata {
    name        = each.value.name
    labels      = each.value.labels
    annotations = each.value.annotations
  }

  value             = each.value.value
  description       = each.value.description
  global_default    = each.value.global_default
  preemption_policy = each.value.preemption_policy
}
