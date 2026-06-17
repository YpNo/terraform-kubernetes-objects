resource "kubernetes_role_v1" "this" {
  for_each = { for r in var.roles : r.name => r }

  metadata {
    name      = each.value.name
    namespace = each.value.namespace
  }

  dynamic "rule" {
    for_each = { for k, v in each.value.rules : k => v }

    content {
      api_groups     = rule.value.api_groups
      resources      = rule.value.resources
      resource_names = rule.value.resource_names
      verbs          = rule.value.verbs
    }
  }
}
