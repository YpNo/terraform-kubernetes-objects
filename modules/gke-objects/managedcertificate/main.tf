resource "kubernetes_manifest" "this" {
  for_each = { for mc in var.managed_certificates : mc.name => mc }

  manifest = {
    "apiVersion" = "networking.gke.io/v1"
    "kind"       = "ManagedCertificate"
    "metadata" = {
      "name"        = each.value.name
      "namespace"   = each.value.namespace
      "labels"      = each.value.labels
      "annotations" = each.value.annotations
    }
    "spec" = merge(
      {
        "domains" = each.value.domains
      },
      each.value.issuer_ref != null ? {
        "configureManagedCertificate" = {
          "issuerRef" = {
            "kind" = each.value.issuer_ref.kind
            "name" = each.value.issuer_ref.name
            (each.value.issuer_ref.group != null ? "group" : null) : each.value.issuer_ref.group,
          }
        }
      } : {}
    )
  }

  field_manager {
    force_conflicts = true
  }
}
