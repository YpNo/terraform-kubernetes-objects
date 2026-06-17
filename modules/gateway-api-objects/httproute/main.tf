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
              filter.request_redirect != null ? {
                "requestRedirect" = {
                  "scheme"   = filter.request_redirect.scheme
                  "hostname" = filter.request_redirect.hostname
                  "path" = filter.request_redirect.path != null ? {
                    "type"               = filter.request_redirect.path.type
                    "replaceFullPath"    = filter.request_redirect.path.replace_full_path
                    "replacePrefixMatch" = filter.request_redirect.path.replace_prefix_match
                  } : null
                  "port"       = filter.request_redirect.port
                  "statusCode" = filter.request_redirect.status_code
                }
              } : {},
              filter.url_rewrite != null ? {
                "urlRewrite" = {
                  "hostname" = filter.url_rewrite.hostname
                  "path" = filter.url_rewrite.path != null ? {
                    "type"               = filter.url_rewrite.path.type
                    "replaceFullPath"    = filter.url_rewrite.path.replace_full_path
                    "replacePrefixMatch" = filter.url_rewrite.path.replace_prefix_match
                  } : null
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
              } : {},
              filter.extension_ref != null ? {
                "extensionRef" = {
                  "group" = filter.extension_ref.group
                  "kind"  = filter.extension_ref.kind
                  "name"  = filter.extension_ref.name
                }
              } : {}
            )
          ]
          "timeouts" = rule.timeouts != null ? {
            "request"        = rule.timeouts.request
            "backendRequest" = rule.timeouts.backend_request
          } : null
          "backendRefs" = [
            for backend in rule.backend_refs : {
              "name"      = backend.name
              "namespace" = backend.namespace
              "port"      = backend.port
              "weight"    = backend.weight
              "filters" = [
                for filter in backend.filters : merge(
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
                  filter.request_redirect != null ? {
                    "requestRedirect" = {
                      "scheme"   = filter.request_redirect.scheme
                      "hostname" = filter.request_redirect.hostname
                      "path" = filter.request_redirect.path != null ? {
                        "type"               = filter.request_redirect.path.type
                        "replaceFullPath"    = filter.request_redirect.path.replace_full_path
                        "replacePrefixMatch" = filter.request_redirect.path.replace_prefix_match
                      } : null
                      "port"       = filter.request_redirect.port
                      "statusCode" = filter.request_redirect.status_code
                    }
                  } : {},
                  filter.url_rewrite != null ? {
                    "urlRewrite" = {
                      "hostname" = filter.url_rewrite.hostname
                      "path" = filter.url_rewrite.path != null ? {
                        "type"               = filter.url_rewrite.path.type
                        "replaceFullPath"    = filter.url_rewrite.path.replace_full_path
                        "replacePrefixMatch" = filter.url_rewrite.path.replace_prefix_match
                      } : null
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
                  } : {},
                  filter.extension_ref != null ? {
                    "extensionRef" = {
                      "group" = filter.extension_ref.group
                      "kind"  = filter.extension_ref.kind
                      "name"  = filter.extension_ref.name
                    }
                  } : {}
                )
              ]
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
