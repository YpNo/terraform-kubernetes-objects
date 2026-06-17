variable "envoy_filters" {
  description = "A list of Istio EnvoyFilter configurations."
  type = list(object({
    name        = string
    namespace   = string
    labels      = optional(map(string), {})
    annotations = optional(map(string), {})

    # Criteria to select the specific set of pods/VMs on which this EnvoyFilter applies.
    # If omitted, the EnvoyFilter applies to all workloads in the namespace.
    workload_selector = optional(object({
      labels = map(string)
    }))

    # One or more patches to apply to the generated Envoy configuration.
    config_patches = optional(list(object({
      # Where in the Envoy configuration the patch applies, e.g.,
      # "LISTENER", "FILTER_CHAIN", "NETWORK_FILTER", "HTTP_FILTER", "ROUTE_CONFIGURATION",
      # "VIRTUAL_HOST", "HTTP_ROUTE", "CLUSTER", "EXTENSION_CONFIG", "BOOTSTRAP", "LISTENER_FILTER".
      apply_to = string

      # Match conditions selecting the object to patch. The nested listener,
      # routeConfiguration and cluster blocks are free-form maps mirroring the
      # Envoy match semantics.
      match = optional(object({
        context             = optional(string) # "ANY", "SIDECAR_INBOUND", "SIDECAR_OUTBOUND", "GATEWAY"
        listener            = optional(any)
        route_configuration = optional(any)
        cluster             = optional(any)
      }))

      # The patch to apply along with the operation.
      patch = object({
        # "MERGE", "ADD", "REMOVE", "INSERT_BEFORE", "INSERT_AFTER", "INSERT_FIRST", "REPLACE"
        operation = string
        # Free-form structure merged into / used to build the target object.
        value = optional(any)
      })
    })), [])
  }))

  validation {
    condition = alltrue([
      for ef in var.envoy_filters :
      alltrue([
        for cp in ef.config_patches :
        contains([
          "MERGE", "ADD", "REMOVE", "INSERT_BEFORE", "INSERT_AFTER", "INSERT_FIRST", "REPLACE"
        ], cp.patch.operation)
      ])
    ])
    error_message = "Invalid patch 'operation'. Must be one of: 'MERGE', 'ADD', 'REMOVE', 'INSERT_BEFORE', 'INSERT_AFTER', 'INSERT_FIRST', 'REPLACE'."
  }
}
