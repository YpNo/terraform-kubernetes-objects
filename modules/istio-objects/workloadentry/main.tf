resource "kubernetes_manifest" "this" {
  for_each = { for we in var.workload_entries : we.name => we }

  manifest = {
    "apiVersion" = "networking.istio.io/v1beta1"
    "kind"       = "WorkloadEntry"
    "metadata" = merge({
      "name"      = each.value.name
      "namespace" = each.value.namespace
      },
      each.value.labels != null ? { labels = each.value.labels } : {},
      each.value.annotations != null ? { annotations = each.value.annotations } : {},
    )
    "spec" = merge(
      each.value.address != null ? { "address" = each.value.address } : {},
      length(each.value.ports) > 0 ? { "ports" = each.value.ports } : {},
      length(each.value.workload_labels) > 0 ? { "labels" = each.value.workload_labels } : {},
      each.value.network != null ? { "network" = each.value.network } : {},
      each.value.locality != null ? { "locality" = each.value.locality } : {},
      each.value.weight != null ? { "weight" = each.value.weight } : {},
      each.value.service_account != null ? { "serviceAccount" = each.value.service_account } : {},
    )
  }

  field_manager {
    force_conflicts = true
  }
}
