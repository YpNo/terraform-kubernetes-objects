variable "compute_classes" {
  description = "A list of ComputeClass objects to create."
  type = list(object({
    name        = string
    namespace   = optional(string)
    labels      = optional(map(string))
    annotations = optional(map(string))
    active_migration = optional(object({
      optimizeRulePriority = optional(bool)
      whenUnsatisfiable    = optional(string)
    }))
    autoscaling_policy = optional(object({
      consolidationDelayMinutes = optional(number)
      consolidationThreshold    = optional(number)
      gpuConsolidationThreshold = optional(number)
    }), {})
    node_pool_auto_creation_enabled = optional(bool, true)
    priority_defaults = optional(object({
      machine_family = optional(string)
      machine_type   = optional(string)
      location       = optional(string)
      min_cores      = optional(number)
      min_memory_gb  = optional(number)
      spot           = optional(bool)
    }), {})
    priorities = list(object({
      machine_family = optional(string)
      machine_type   = optional(string)
      location       = optional(string)
      min_cores      = optional(number)
      min_memory_gb  = optional(number)
      spot           = optional(bool)
      gpu = optional(object({
        type  = string
        count = number
      }))
    }))
  }))
  default = []
}
