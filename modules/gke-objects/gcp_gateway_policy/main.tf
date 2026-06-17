resource "kubernetes_manifest" "this" {
  for_each = { for gp in var.gcp_gateway_policies : gp.name => gp }

  manifest = {
    "apiVersion" = "networking.gke.io/v1"
    "kind"       = "GCPGatewayPolicy"
    "metadata" = {
      "name"        = each.value.name
      "namespace"   = each.value.namespace
      "labels"      = each.value.labels
      "annotations" = each.value.annotations
    }
    "spec" = {
      "default" = merge(
        each.value.allow_global_access != null ? { "allowGlobalAccess" = each.value.allow_global_access } : {},
        each.value.ssl_policy != null ? { "sslPolicy" = each.value.ssl_policy } : {},
        each.value.region != null ? { "region" = each.value.region } : {},
      )
      "targetRef" = merge(
        {
          "group" = each.value.target_ref.group
          "kind"  = each.value.target_ref.kind
          "name"  = each.value.target_ref.name
        },
        each.value.target_ref.namespace != null ? { "namespace" = each.value.target_ref.namespace } : {},
      )
    }
  }

  field_manager {
    force_conflicts = true
  }
}
