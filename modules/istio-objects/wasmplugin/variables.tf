variable "wasm_plugins" {
  description = "A list of Istio WasmPlugin configurations."
  type = list(object({
    name        = string
    namespace   = string
    labels      = optional(map(string))
    annotations = optional(map(string))

    # Selects the set of pods/VMs on which this WasmPlugin is applied.
    # If omitted, the WasmPlugin applies to all workloads in the namespace.
    selector = optional(object({
      match_labels = map(string)
    }))

    # URL of a Wasm module or OCI container. If no scheme is present, defaults to "oci://".
    url = string

    # SHA256 checksum used to verify the Wasm module or OCI container.
    sha256 = optional(string)

    # Pull behavior for OCI images: "IfNotPresent", "Always", or "UNSPECIFIED_POLICY".
    image_pull_policy = optional(string)

    # Name of a Kubernetes Secret holding OCI registry pull credentials.
    image_pull_secret = optional(string)

    # Plugin identifier used in the Envoy configuration.
    plugin_name = optional(string)

    # Filter chain insertion point: "UNSPECIFIED_PHASE", "AUTHN", "AUTHZ", "STATS".
    phase = optional(string)

    # Ordering within the same phase. Larger numbers run earlier (descending order).
    priority = optional(number)

    # Extension type: "HTTP", "NETWORK", or "UNSPECIFIED_PLUGIN_TYPE".
    type = optional(string)

    # Failure behavior: "FAIL_CLOSE", "FAIL_OPEN", "FAIL_RELOAD".
    fail_strategy = optional(string)

    # Free-form configuration passed to the plugin (rendered as-is into pluginConfig).
    plugin_config = optional(any)

    # Configuration for the Wasm VM.
    vm_config = optional(object({
      env = list(object({
        name = string
        # "INLINE" (value field) or "HOST" (read from host environment).
        value_from = optional(string)
        value      = optional(string)
      }))
    }))
  }))

  validation {
    condition = alltrue([
      for p in var.wasm_plugins :
      p.phase == null || contains(["UNSPECIFIED_PHASE", "AUTHN", "AUTHZ", "STATS"], p.phase)
    ])
    error_message = "Invalid 'phase' for WasmPlugin. Must be one of: 'UNSPECIFIED_PHASE', 'AUTHN', 'AUTHZ', 'STATS'."
  }

  validation {
    condition = alltrue([
      for p in var.wasm_plugins :
      p.image_pull_policy == null || contains(["UNSPECIFIED_POLICY", "IfNotPresent", "Always"], p.image_pull_policy)
    ])
    error_message = "Invalid 'image_pull_policy' for WasmPlugin. Must be one of: 'UNSPECIFIED_POLICY', 'IfNotPresent', 'Always'."
  }

  validation {
    condition = alltrue([
      for p in var.wasm_plugins :
      p.type == null || contains(["UNSPECIFIED_PLUGIN_TYPE", "HTTP", "NETWORK"], p.type)
    ])
    error_message = "Invalid 'type' for WasmPlugin. Must be one of: 'UNSPECIFIED_PLUGIN_TYPE', 'HTTP', 'NETWORK'."
  }

  validation {
    condition = alltrue([
      for p in var.wasm_plugins :
      p.fail_strategy == null || contains(["FAIL_CLOSE", "FAIL_OPEN", "FAIL_RELOAD"], p.fail_strategy)
    ])
    error_message = "Invalid 'fail_strategy' for WasmPlugin. Must be one of: 'FAIL_CLOSE', 'FAIL_OPEN', 'FAIL_RELOAD'."
  }
}
