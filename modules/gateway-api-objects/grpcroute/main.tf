resource "kubernetes_manifest" "this" {
  for_each = { for r in var.grpc_routes : "${r.namespace}-${r.name}" => r }

  manifest = {
    "apiVersion" = "gateway.networking.k8s.io/v1"
    "kind"       = "GRPCRoute"
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
          "matches" = [
            for match in rule.matches : {
              "method" = match.method != null ? {
                "type"    = match.method.type
                "service" = match.method.service
                "method"  = match.method.method
              } : null
              "headers" = [
                for header in match.headers : {
                  "type"  = header.type
                  "name"  = header.name
                  "value" = header.value
                }
              ]
            }
          ]
          "filters" = [
            for filter in rule.filters : merge(
              { "type" = filter.type },
              filter.request_header_modifier != null ? {
                "requestHeaderModifier" = {
                  "set"    = [for h in filter.request_header_modifier.set : { name = h.name, value = h.value }]
                  "add"    = [for h in filter.request_header_modifier.add : { name = h.name, value = h.value }]
                  "remove" = filter.request_header_modifier.remove
                }
              } : {},
              filter.response_header_modifier != null ? {
                "responseHeaderModifier" = {
                  "set"    = [for h in filter.response_header_modifier.set : { name = h.name, value = h.value }]
                  "add"    = [for h in filter.response_header_modifier.add : { name = h.name, value = h.value }]
                  "remove" = filter.response_header_modifier.remove
                }
              } : {},
              filter.request_mirror != null ? {
                "requestMirror" = {
                  "backendRef" = {
                    "group"     = filter.request_mirror.backend_ref.group
                    "kind"      = filter.request_mirror.backend_ref.kind
                    "name"      = filter.request_mirror.backend_ref.name
                    "namespace" = filter.request_mirror.backend_ref.namespace
                    "port"      = filter.request_mirror.backend_ref.port
                  }
                  "percent" = filter.request_mirror.percent
                  "fraction" = filter.request_mirror.fraction != null ? {
                    "numerator"   = filter.request_mirror.fraction.numerator
                    "denominator" = filter.request_mirror.fraction.denominator
                  } : null
                }
              } : {}
            )
          ]
          "backendRefs" = [
            for backend in rule.backend_refs : {
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
