resource "kubernetes_manifest" "this" {
  for_each = { for r in var.http_routes : "${r.namespace}-${r.name}" => r }

  manifest = {
    "apiVersion" = "gateway.networking.k8s.io/v1"
    "kind"       = "HTTPRoute"
    "metadata" = {
      "name"        = each.value.name
      "namespace"   = each.value.namespace
      "labels"      = each.value.labels
      "annotations" = each.value.annotations
    }
    "spec" = {
      "parentRefs" = [
        for ref in each.value.parent_refs : {
          "name"        = ref.name
          "namespace"   = ref.namespace
          "sectionName" = ref.section_name
        }
      ]
      "hostnames" = each.value.hostnames
      "rules" = [
        for rule in each.value.rules : {
          "matches" = [
            for match in rule.matches : {
              "path" = match.path != null ? {
                "type"  = match.path.type
                "value" = match.path.value
              } : null
              "headers" = [
                for header in match.headers : {
                  "type"  = header.type
                  "name"  = header.name
                  "value" = header.value
                }
              ]
              "queryParams" = [
                for param in match.query_params : {
                  "type"  = param.type
                  "name"  = param.name
                  "value" = param.value
                }
              ]
              "method" = match.method
            }
          ]
          "filters" = [
            for filter in rule.filters : {
              "type" = filter.type
              "requestHeaderModifier" = filter.request_header_modifier != null ? {
                "set"    = [for h in filter.request_header_modifier.set : { name = h.name, value = h.value }]
                "add"    = [for h in filter.request_header_modifier.add : { name = h.name, value = h.value }]
                "remove" = filter.request_header_modifier.remove
              } : null
              "requestRedirect" = filter.request_redirect != null ? {
                "scheme"   = filter.request_redirect.scheme
                "hostname" = filter.request_redirect.hostname
                "path" = {
                  "type"               = filter.request_redirect.path.type
                  "replaceFullPath"    = filter.request_redirect.path.replace_full_path
                  "replacePrefixMatch" = filter.request_redirect.path.replace_prefix_match
                }
                "port"       = filter.request_redirect.port
                "statusCode" = filter.request_redirect.status_code
              } : null
            }
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
