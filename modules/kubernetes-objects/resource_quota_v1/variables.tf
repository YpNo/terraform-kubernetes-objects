variable "resource_quotas" {
  description = "A list of Kubernetes ResourceQuota configurations."
  type = list(object({
    name        = string
    namespace   = string
    labels      = optional(map(string), {}) # Labels for the ResourceQuota metadata
    annotations = optional(map(string), {}) # Annotations for the ResourceQuota metadata

    # The set of desired hard limits for each named resource,
    # e.g. { "requests.cpu" = "4", "pods" = "10" }.
    hard = optional(map(string), {})

    # A collection of filters that must match each object tracked by the quota,
    # e.g. ["BestEffort", "NotTerminating"].
    scopes = optional(list(string), [])

    # Filters expressed using a scope selector operator and possible values.
    scope_selector = optional(object({
      match_expressions = optional(list(object({
        scope_name = string                     # e.g. "PriorityClass", "Terminating"
        operator   = string                     # "In", "NotIn", "Exists", "DoesNotExist"
        values     = optional(list(string), []) # Required for In/NotIn; empty for Exists/DoesNotExist
      })), [])
    }))
  }))

  validation {
    condition = alltrue([
      for rq in var.resource_quotas :
      rq.scope_selector == null ? true : alltrue([
        for me in rq.scope_selector.match_expressions :
        contains(["In", "NotIn", "Exists", "DoesNotExist"], me.operator)
      ])
    ])
    error_message = "Invalid 'scope_selector.match_expressions.operator'. Must be 'In', 'NotIn', 'Exists' or 'DoesNotExist'."
  }

  # Example usage in a `main.tf` or `terraform.tfvars`:
  # resource_quotas = [
  #   {
  #     name      = "compute-quota"
  #     namespace = "team-a"
  #     hard = {
  #       "requests.cpu"    = "4"
  #       "requests.memory" = "8Gi"
  #       "limits.cpu"      = "8"
  #       "limits.memory"   = "16Gi"
  #       "pods"            = "20"
  #     }
  #     scopes = ["NotTerminating"]
  #     scope_selector = {
  #       match_expressions = [
  #         {
  #           scope_name = "PriorityClass"
  #           operator   = "In"
  #           values     = ["high"]
  #         }
  #       ]
  #     }
  #   }
  # ]
}
