resource "kubernetes_manifest" "this" {
  for_each = { for cc in var.compute_classes : cc.name => cc }

  manifest = {
    "apiVersion" = "cloud.google.com/v1"
    "kind"       = "ComputeClass"
    "metadata" = {
      "name"        = each.value.name
      "namespace"   = each.value.namespace
      "labels"      = each.value.labels
      "annotations" = each.value.annotations
    }
    "spec" = {
      "activeMigration" = each.value.active_migration
      "autoscalingPolicy" = {
        "consolidationDelayMinutes" = each.value.autoscaling_policy.consolidation_delay_minutes
        "consolidationThreshold"    = each.value.autoscaling_policy.consolidation_threshold
        "gpuConsolidationThreshold" = each.value.autoscaling_policy.gpu_consolidation_threshold
      }
      "nodePoolAutoCreation" = {
        "enabled" = each.value.node_pool_auto_creation_enabled
      }
      "priorityDefaults" = {
        "machineFamily" = each.value.priority_defaults.machine_family
        "machineType"   = each.value.priority_defaults.machine_type
        "location"      = each.value.priority_defaults.location
        "minCores"      = each.value.priority_defaults.min_cores
        "minMemoryGb"   = each.value.priority_defaults.min_memory_gb
        "spot"          = each.value.priority_defaults.spot
      }
      "priorities" = [
        for priority in each.value.priorities : merge(
          priority.machine_family != null ? { "machineFamily" = priority.machine_family } : {},
          priority.machine_type != null ? { "machineType" = priority.machine_type } : {},
          priority.location != null ? { "location" = priority.location } : {},
          priority.min_cores != null ? { "minCores" = priority.min_cores } : {},
          priority.min_memory_gb != null ? { "minMemoryGb" = priority.min_memory_gb } : {},
          priority.spot != null ? { "spot" = priority.spot } : {},
          priority.flex_start != null ? { "flexStart" = priority.flex_start } : {},
          priority.priority_score != null ? { "priorityScore" = priority.priority_score } : {},
          priority.nodepools != null ? { "nodepools" = priority.nodepools } : {},
          priority.gpu != null ? {
            "gpu" = {
              "type"  = priority.gpu.type
              "count" = priority.gpu.count
            }
          } : {},
          priority.reservations != null ? {
            "reservations" = merge(
              { "affinity" = priority.reservations.affinity },
              priority.reservations.specific != null ? {
                "specific" = [
                  for r in priority.reservations.specific : merge(
                    { "name" = r.name },
                    r.reservation_block != null ? { "reservationBlock" = { "name" = r.reservation_block } } : {},
                  )
                ]
              } : {},
            )
          } : {},
        )
      ]
    }
  }

  field_manager {
    force_conflicts = true
  }
}
