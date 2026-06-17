variable "limit_ranges" {
  description = "A list of Kubernetes LimitRange configurations."
  type = list(object({
    name        = string
    namespace   = string
    labels      = optional(map(string), {}) # Labels for the LimitRange metadata
    annotations = optional(map(string), {}) # Annotations for the LimitRange metadata

    # The list of limit items enforced in the namespace.
    limits = optional(list(object({
      type                    = string                    # "Pod", "Container" or "PersistentVolumeClaim"
      max                     = optional(map(string), {}) # Max usage constraints by resource name
      min                     = optional(map(string), {}) # Min usage constraints by resource name
      default                 = optional(map(string), {}) # Default limit value when omitted (Container only)
      default_request         = optional(map(string), {}) # Default request value when omitted (Container only)
      max_limit_request_ratio = optional(map(string), {}) # Max ratio of limit to request per resource
    })), [])
  }))

  validation {
    condition = alltrue([
      for lr in var.limit_ranges :
      alltrue([
        for limit in lr.limits :
        contains(["Pod", "Container", "PersistentVolumeClaim"], limit.type)
      ])
    ])
    error_message = "Invalid 'limits.type'. Must be 'Pod', 'Container' or 'PersistentVolumeClaim'."
  }

  # Example usage in a `main.tf` or `terraform.tfvars`:
  # limit_ranges = [
  #   {
  #     name      = "default-limits"
  #     namespace = "team-a"
  #     limits = [
  #       {
  #         type    = "Container"
  #         default = { cpu = "200m", memory = "256Mi" }
  #         default_request = { cpu = "100m", memory = "128Mi" }
  #         max = { cpu = "1", memory = "1Gi" }
  #         min = { cpu = "50m", memory = "64Mi" }
  #       },
  #       {
  #         type = "PersistentVolumeClaim"
  #         min  = { storage = "1Gi" }
  #         max  = { storage = "10Gi" }
  #       }
  #     ]
  #   }
  # ]
}
