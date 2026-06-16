resource "kubernetes_manifest" "this" {
  for_each = { for se in var.service_entries : se.name => se }

  manifest = {
    "apiVersion" = "networking.istio.io/v1beta1"
    "kind"       = "ServiceEntry"
    "metadata" = merge({
      "name"      = each.value.name
      "namespace" = each.value.namespace
      },
      each.value.labels != null ? { labels = each.value.labels } : {},
      each.value.annotations != null ? { annotations = each.value.annotations } : {},
    )
    "spec" = merge(
      {
        "hosts" = each.value.hosts
        "ports" = [
          for port in each.value.ports : merge(
            {
              "number"   = port.number
              "name"     = port.name
              "protocol" = port.protocol
            },
            port.target_port != null ? { "targetPort" = port.target_port } : {},
          )
        ]
      },
      length(each.value.addresses) > 0 ? { "addresses" = each.value.addresses } : {},
      each.value.location != null ? { "location" = each.value.location } : {},
      each.value.resolution != null ? { "resolution" = each.value.resolution } : {},
      length(each.value.endpoints) > 0 ? {
        "endpoints" = [
          for ep in each.value.endpoints : merge(
            {
              "address" = ep.address
              "ports"   = ep.ports # This is a map: { "http": 80, "https": 443 }
            },
            length(ep.labels) > 0 ? { "labels" = ep.labels } : {},
            ep.network != null ? { "network" = ep.network } : {},
            ep.locality != null ? { "locality" = ep.locality } : {},
            ep.weight != null ? { "weight" = ep.weight } : {},
            ep.service_account != null ? { "serviceAccount" = ep.service_account } : {},
            ep.tls_mode != null ? { "tlsMode" = ep.tls_mode } : {},
          )
        ]
      } : {},
      length(each.value.export_to) > 0 ? { "exportTo" = each.value.export_to } : {},
    )
  }

  field_manager {
    force_conflicts = true
  }
}
