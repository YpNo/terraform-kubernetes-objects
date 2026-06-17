resource "kubernetes_manifest" "this" {
  for_each = { for s in var.sidecars : s.name => s }

  manifest = {
    "apiVersion" = "networking.istio.io/v1beta1"
    "kind"       = "Sidecar"
    "metadata" = merge(
      {
        "name"      = each.value.name
        "namespace" = each.value.namespace
      },
      length(each.value.labels) > 0 ? { "labels" = each.value.labels } : {},
      length(each.value.annotations) > 0 ? { "annotations" = each.value.annotations } : {},
    )
    "spec" = merge(
      each.value.workload_selector != null ? { "workloadSelector" = { "labels" = each.value.workload_selector.labels } } : {},
      length(each.value.ingress) > 0 ? {
        "ingress" = [
          for ing in each.value.ingress : merge(
            {
              "port" = {
                "number"   = ing.port.number
                "protocol" = ing.port.protocol
                "name"     = ing.port.name
              }
            },
            ing.bind != null ? { "bind" = ing.bind } : {},
            ing.capture_mode != null ? { "captureMode" = ing.capture_mode } : {},
            ing.default_endpoint != null ? { "defaultEndpoint" = ing.default_endpoint } : {},
          )
        ]
      } : {},
      length(each.value.egress) > 0 ? {
        "egress" = [
          for eg in each.value.egress : merge(
            {
              "hosts" = eg.hosts
            },
            eg.port != null ? {
              "port" = {
                "number"   = eg.port.number
                "protocol" = eg.port.protocol
                "name"     = eg.port.name
              }
            } : {},
            eg.bind != null ? { "bind" = eg.bind } : {},
            eg.capture_mode != null ? { "captureMode" = eg.capture_mode } : {},
          )
        ]
      } : {},
      each.value.outbound_traffic_policy != null ? {
        "outboundTrafficPolicy" = { "mode" = each.value.outbound_traffic_policy.mode }
      } : {},
    )
  }

  field_manager {
    force_conflicts = true
  }
}
