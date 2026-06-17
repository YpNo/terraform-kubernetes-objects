resource "kubernetes_manifest" "this" {
  for_each = { for pa in var.peer_authentications : pa.name => pa }

  manifest = {
    "apiVersion" = "security.istio.io/v1beta1"
    "kind"       = "PeerAuthentication"
    "metadata" = merge(
      {
        "name" = each.value.name
        (each.value.namespace != null ? "namespace" : null) : each.value.namespace,
      },
      each.value.labels != null ? { "labels" = each.value.labels } : {},
      each.value.annotations != null ? { "annotations" = each.value.annotations } : {},
    )
    "spec" = merge(
      each.value.selector != null ? { "selector" = { "matchLabels" = each.value.selector } } : {},
      each.value.mtls_mode != null ? { "mtls" = { "mode" = each.value.mtls_mode } } : {},
      length(each.value.port_level_mtls) > 0 ? { "portLevelMtls" = each.value.port_level_mtls } : {},
    )
  }

  field_manager {
    force_conflicts = true
  }
}