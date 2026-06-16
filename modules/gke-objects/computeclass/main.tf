resource "kubernetes_manifest" "this" {
  for_each = { for cc in var.compute_classes : cc.name => cc }

  manifest = {
    "apiVersion" = "compute.gke.io/v1alpha1"
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
        for priority in each.value.priorities : {
          "machineFamily" = priority.machine_family
          "machineType"   = priority.machine_type
          "location"      = priority.location
          "minCores"      = priority.min_cores
          "minMemoryGb"   = priority.min_memory_gb
          "spot"          = priority.spot
          "gpu" = priority.gpu != null ? {
            "type"  = priority.gpu.type
            "count" = priority.gpu.count
          } : null
        }
      ]
    }
  }

  field_manager {
    force_conflicts = true
  }
}
