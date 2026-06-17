resource "kubernetes_cluster_role_v1" "this" {
  for_each = { for cr in var.cluster_roles : cr.name => cr }

  metadata {
    name = each.value.name
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
