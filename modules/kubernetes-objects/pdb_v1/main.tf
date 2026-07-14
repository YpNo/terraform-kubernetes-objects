resource "kubernetes_pod_disruption_budget_v1" "this" {
  for_each = { for pdb in var.pdbs : pdb.name => pdb }

  metadata {
    name      = each.value.name
    namespace = each.value.namespace
    labels    = each.value.labels
  }
  spec {
    min_available   = each.value.min_available
    max_unavailable = each.value.max_unavailable

    selector {
      match_labels = each.value.selector.match_labels
      dynamic "match_expressions" {
        for_each = each.value.selector.match_expressions

        content {
          key      = match_expressions.value.key
          operator = match_expressions.value.operator
          values   = match_expressions.value.values
        }
      }
    }
  }
}
