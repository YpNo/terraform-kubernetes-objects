resource "kubernetes_manifest" "this" {
  for_each = { for sap in var.gcp_session_affinity_policies : sap.name => sap }

  manifest = {
    "apiVersion" = "networking.gke.io/v1"
    "kind"       = "GCPSessionAffinityPolicy"
    "metadata" = {
      "name"        = each.value.name
      "namespace"   = each.value.namespace
      "labels"      = each.value.labels
      "annotations" = each.value.annotations
    }
    "spec" = merge(
      each.value.stateful_generated_cookie != null ? {
        "statefulGeneratedCookie" = {
          "cookieTtlSeconds" = each.value.stateful_generated_cookie.cookie_ttl_seconds
        }
      } : {},
      {
        "targetRef" = merge(
          {
            "group" = each.value.target_ref.group
            "kind"  = each.value.target_ref.kind
            "name"  = each.value.target_ref.name
          },
          each.value.target_ref.namespace != null ? { "namespace" = each.value.target_ref.namespace } : {},
        )
      },
    )
  }

  field_manager {
    force_conflicts = true
  }
}
