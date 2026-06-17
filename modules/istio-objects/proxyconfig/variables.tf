variable "proxy_configs" {
  description = "A list of Istio ProxyConfig configurations."
  type = list(object({
    name        = string
    namespace   = string
    labels      = optional(map(string))
    annotations = optional(map(string))

    # Selects the set of pods/VMs on which this ProxyConfig is applied.
    # If omitted, the ProxyConfig applies to all workloads in the namespace.
    selector = optional(object({
      match_labels = map(string)
    }))

    # Number of worker threads to run. If unset, determined from CPU limits.
    concurrency = optional(number)

    # Additional environment variables for the proxy. Names starting with
    # "ISTIO_META_" are also included in the bootstrap configuration.
    environment_variables = optional(map(string), {})

    # Proxy image details.
    image = optional(object({
      # "default", "debug", or "distroless".
      image_type = string
    }))
  }))

  validation {
    condition = alltrue([
      for pc in var.proxy_configs :
      pc.image == null || contains(["default", "debug", "distroless"], try(pc.image.image_type, "N/A"))
    ])
    error_message = "Invalid 'image_type' for ProxyConfig. Must be one of: 'default', 'debug', 'distroless'."
  }
}
