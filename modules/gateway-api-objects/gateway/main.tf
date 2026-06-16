resource "kubernetes_manifest" "this" {
  for_each = { for g in var.gateways : "${g.namespace}-${g.name}" => g }

  manifest = {
    "apiVersion" = "gateway.networking.k8s.io/v1"
    "kind"       = "Gateway"
    "metadata" = {
      "name"        = each.value.name
      "namespace"   = each.value.namespace
      "labels"      = each.value.labels
      "annotations" = each.value.annotations
    }
    "spec" = {
      "gatewayClassName" = each.value.gateway_class_name
      "listeners" = [
        for listener in each.value.listeners : {
          "name"     = listener.name
          "protocol" = listener.protocol
          "port"     = listener.port
          "hostname" = listener.hostname
          "tls" = listener.tls != null ? {
            "mode" = listener.tls.mode
            "certificateRefs" = [
              for cert in listener.tls.certificate_refs : {
                "group"     = cert.group
                "kind"      = cert.kind
                "name"      = cert.name
                "namespace" = cert.namespace
              }
            ]
          } : null
          "allowedRoutes" = listener.allowed_routes != null ? {
            "namespaces" = listener.allowed_routes.namespaces != null ? {
              "from" = listener.allowed_routes.namespaces.from
              "selector" = listener.allowed_routes.namespaces.selector != null ? {
                "matchLabels" = listener.allowed_routes.namespaces.selector.match_labels
              } : null
            } : null
            "kinds" = [
              for kind in listener.allowed_routes.kinds : {
                "group" = kind.group
                "kind"  = kind.kind
              }
            ]
          } : null
        }
      ]
      "addresses" = [
        for address in each.value.addresses : {
          "type"  = address.type
          "value" = address.value
        }
      ]
    }
  }

  field_manager {
    force_conflicts = true
  }
}
