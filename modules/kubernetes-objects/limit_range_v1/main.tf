resource "kubernetes_limit_range_v1" "this" {
  for_each = { for lr in var.limit_ranges : lr.name => lr }

  metadata {
    name        = each.value.name
    namespace   = each.value.namespace
    labels      = each.value.labels
    annotations = each.value.annotations
  }

  spec {
    dynamic "limit" {
      for_each = each.value.limits

      content {
        type                    = limit.value.type
        max                     = limit.value.max
        min                     = limit.value.min
        default                 = limit.value.default
        default_request         = limit.value.default_request
        max_limit_request_ratio = limit.value.max_limit_request_ratio
      }
    }
  }
}
