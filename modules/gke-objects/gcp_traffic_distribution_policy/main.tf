resource "kubernetes_manifest" "this" {
  for_each = { for tdp in var.gcp_traffic_distribution_policies : tdp.name => tdp }

  manifest = {
    "apiVersion" = "networking.gke.io/v1"
    "kind"       = "GCPTrafficDistributionPolicy"
    "metadata" = {
      "name"        = each.value.name
      "namespace"   = each.value.namespace
      "labels"      = each.value.labels
      "annotations" = each.value.annotations
    }
    "spec" = merge(
      each.value.default != null ? {
        "default" = merge(
          each.value.default.service_lb_algorithm != null ? { "serviceLbAlgorithm" = each.value.default.service_lb_algorithm } : {},
          each.value.default.locality_lb_algorithm != null ? { "localityLbAlgorithm" = each.value.default.locality_lb_algorithm } : {},
          each.value.default.auto_capacity_drain != null ? {
            "autoCapacityDrain" = {
              "enableAutoCapacityDrain" = each.value.default.auto_capacity_drain.enable_auto_capacity_drain
            }
          } : {},
          each.value.default.failover_config != null ? {
            "failoverConfig" = {
              "failoverHealthThreshold" = each.value.default.failover_config.failover_health_threshold
            }
          } : {},
        )
      } : {},
      {
        "targetRefs" = [
          for ref in each.value.target_refs : {
            "group" = ref.group
            "kind"  = ref.kind
            "name"  = ref.name
          }
        ]
      },
    )
  }

  field_manager {
    force_conflicts = true
  }
}
