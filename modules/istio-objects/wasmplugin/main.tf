resource "kubernetes_manifest" "this" {
  for_each = { for wp in var.wasm_plugins : wp.name => wp }

  manifest = {
    "apiVersion" = "extensions.istio.io/v1alpha1"
    "kind"       = "WasmPlugin"
    "metadata" = merge({
      "name"      = each.value.name
      "namespace" = each.value.namespace
      },
      each.value.labels != null ? { labels = each.value.labels } : {},
      each.value.annotations != null ? { annotations = each.value.annotations } : {},
    )
    "spec" = merge(
      {
        "url" = each.value.url
      },
      each.value.selector != null ? { "selector" = { "matchLabels" = each.value.selector.match_labels } } : {},
      each.value.sha256 != null ? { "sha256" = each.value.sha256 } : {},
      each.value.image_pull_policy != null ? { "imagePullPolicy" = each.value.image_pull_policy } : {},
      each.value.image_pull_secret != null ? { "imagePullSecret" = each.value.image_pull_secret } : {},
      each.value.plugin_name != null ? { "pluginName" = each.value.plugin_name } : {},
      each.value.phase != null ? { "phase" = each.value.phase } : {},
      each.value.priority != null ? { "priority" = each.value.priority } : {},
      each.value.type != null ? { "type" = each.value.type } : {},
      each.value.fail_strategy != null ? { "failStrategy" = each.value.fail_strategy } : {},
      each.value.plugin_config != null ? { "pluginConfig" = each.value.plugin_config } : {},
      each.value.vm_config != null ? {
        "vmConfig" = {
          "env" = [
            for e in each.value.vm_config.env : merge(
              {
                "name" = e.name
              },
              e.value_from != null ? { "valueFrom" = e.value_from } : {},
              e.value != null ? { "value" = e.value } : {},
            )
          ]
        }
      } : {},
    )
  }

  field_manager {
    force_conflicts = true
  }
}
