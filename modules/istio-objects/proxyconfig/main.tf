resource "kubernetes_manifest" "this" {
  for_each = { for pc in var.proxy_configs : pc.name => pc }

  manifest = {
    "apiVersion" = "networking.istio.io/v1beta1"
    "kind"       = "ProxyConfig"
    "metadata" = merge({
      "name"      = each.value.name
      "namespace" = each.value.namespace
      },
      each.value.labels != null ? { labels = each.value.labels } : {},
      each.value.annotations != null ? { annotations = each.value.annotations } : {},
    )
    "spec" = merge(
      each.value.selector != null ? { "selector" = { "matchLabels" = each.value.selector.match_labels } } : {},
      each.value.concurrency != null ? { "concurrency" = each.value.concurrency } : {},
      length(each.value.environment_variables) > 0 ? { "environmentVariables" = each.value.environment_variables } : {},
      each.value.image != null ? { "image" = { "imageType" = each.value.image.image_type } } : {},
    )
  }

  field_manager {
    force_conflicts = true
  }
}
