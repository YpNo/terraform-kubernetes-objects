resource "kubernetes_resource_quota_v1" "this" {
  for_each = { for rq in var.resource_quotas : rq.name => rq }

  metadata {
    name        = each.value.name
    namespace   = each.value.namespace
    labels      = each.value.labels
    annotations = each.value.annotations
  }

  spec {
    hard   = each.value.hard
    scopes = each.value.scopes

    dynamic "scope_selector" {
      for_each = each.value.scope_selector != null ? [each.value.scope_selector] : []

      content {
        dynamic "match_expression" {
          for_each = scope_selector.value.match_expressions

          content {
            scope_name = match_expression.value.scope_name
            operator   = match_expression.value.operator
            values     = match_expression.value.values
          }
        }
      }
    }
  }
}
