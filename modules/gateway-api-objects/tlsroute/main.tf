resource "kubernetes_manifest" "this" {
  for_each = { for r in var.tls_routes : "${r.namespace}-${r.name}" => r }

  manifest = {
    "apiVersion" = "gateway.networking.k8s.io/v1alpha2"
    "kind"       = "TLSRoute"
    "metadata" = {
      "name"        = each.value.name
      "namespace"   = each.value.namespace
      "labels"      = each.value.labels
      "annotations" = each.value.annotations
    }
    "spec" = {
      "parentRefs" = [
        for ref in each.value.parent_refs : {
          "group"       = ref.group
          "kind"        = ref.kind
          "name"        = ref.name
          "namespace"   = ref.namespace
          "sectionName" = ref.section_name
          "port"        = ref.port
        }
      ]
      "hostnames" = each.value.hostnames
      "rules" = [
        for rule in each.value.rules : {
          "name" = rule.name
          "backendRefs" = [
            for backend in rule.backend_refs : {
              "group"     = backend.group
              "kind"      = backend.kind
              "name"      = backend.name
              "namespace" = backend.namespace
              "port"      = backend.port
              "weight"    = backend.weight
            }
          ]
        }
      ]
    }
  }

  field_manager {
    force_conflicts = true
  }
}
