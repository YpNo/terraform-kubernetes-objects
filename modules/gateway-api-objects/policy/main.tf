resource "kubernetes_manifest" "this" {
  for_each = { for p in var.gateway_policies : "${p.namespace}-${p.name}" => p }

  manifest = {
    "apiVersion" = each.value.api_version
    "kind"       = each.value.kind
    "metadata" = {
      "name"      = each.value.name
      "namespace" = each.value.namespace
      "labels"    = each.value.labels
    }
    "spec" = {
      "targetRef" = {
        "group" = each.value.target_ref.group
        "kind"  = each.value.target_ref.kind
        "name"  = each.value.target_ref.name
      }
      # The 'default' block contains the specific policy configuration
      "default" = each.value.policy_spec
    }
  }

  field_manager {
    force_conflicts = true
  }
}
