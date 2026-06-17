resource "kubernetes_manifest" "this" {
  for_each = { for ef in var.envoy_filters : ef.name => ef }

  manifest = {
    "apiVersion" = "networking.istio.io/v1alpha3"
    "kind"       = "EnvoyFilter"
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
      length(each.value.config_patches) > 0 ? {
        "configPatches" = [
          for cp in each.value.config_patches : merge(
            {
              "applyTo" = cp.apply_to
              "patch" = merge(
                { "operation" = cp.patch.operation },
                cp.patch.value != null ? { "value" = cp.patch.value } : {},
              )
            },
            cp.match != null ? {
              "match" = merge(
                cp.match.context != null ? { "context" = cp.match.context } : {},
                cp.match.listener != null ? { "listener" = cp.match.listener } : {},
                cp.match.route_configuration != null ? { "routeConfiguration" = cp.match.route_configuration } : {},
                cp.match.cluster != null ? { "cluster" = cp.match.cluster } : {},
              )
            } : {},
          )
        ]
      } : {},
    )
  }

  field_manager {
    force_conflicts = true
  }
}
