resource "kubernetes_manifest" "this" {
  for_each = { for saf in var.gcp_session_affinity_filters : saf.name => saf }

  manifest = {
    "apiVersion" = "networking.gke.io/v1"
    "kind"       = "GCPSessionAffinityFilter"
    "metadata" = {
      "name"        = each.value.name
      "namespace"   = each.value.namespace
      "labels"      = each.value.labels
      "annotations" = each.value.annotations
    }
    "spec" = {
      "statefulGeneratedCookie" = {
        "cookieTtlSeconds" = each.value.stateful_generated_cookie.cookie_ttl_seconds
      }
    }
  }

  field_manager {
    force_conflicts = true
  }
}
