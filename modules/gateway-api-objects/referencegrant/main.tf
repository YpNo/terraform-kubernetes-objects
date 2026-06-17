resource "kubernetes_manifest" "this" {
  for_each = { for rg in var.reference_grants : "${rg.namespace}-${rg.name}" => rg }

  manifest = {
    "apiVersion" = "gateway.networking.k8s.io/v1beta1"
    "kind"       = "ReferenceGrant"
    "metadata" = {
      "name"        = each.value.name
      "namespace"   = each.value.namespace
      "labels"      = each.value.labels
      "annotations" = each.value.annotations
    }
    "spec" = {
      "from" = [
        for from_ref in each.value.from : {
          "group"     = from_ref.group
          "kind"      = from_ref.kind
          "namespace" = from_ref.namespace
        }
      ]
      "to" = [
        for to_ref in each.value.to : {
          "group" = to_ref.group
          "kind"  = to_ref.kind
          "name"  = to_ref.name
        }
      ]
    }
  }

  field_manager {
    force_conflicts = true
  }
}
