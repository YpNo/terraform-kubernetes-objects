variable "sidecars" {
  description = "A list of Istio Sidecar configurations."
  type = list(object({
    name        = string
    namespace   = string
    labels      = optional(map(string), {})
    annotations = optional(map(string), {})

    # Criteria to select the specific set of pods/VMs on which this Sidecar applies.
    # If omitted, the Sidecar applies to all workloads in the namespace.
    workload_selector = optional(object({
      labels = map(string)
    }))

    # Inbound listeners for traffic to the attached workload(s).
    ingress = optional(list(object({
      port = object({
        number   = number
        protocol = string # "HTTP", "HTTPS", "GRPC", "HTTP2", "MONGO", "TCP", "TLS"
        name     = string
      })
      bind             = optional(string) # IP/Unix domain socket the listener binds to
      capture_mode     = optional(string) # "DEFAULT", "IPTABLES", "NONE"
      default_endpoint = optional(string) # e.g., "127.0.0.1:8080" or "unix:///path/to/socket"
    })), [])

    # Outbound listeners describing the egress traffic from the attached workload(s).
    egress = optional(list(object({
      port = optional(object({
        number   = number
        protocol = string
        name     = string
      }))
      bind         = optional(string)
      capture_mode = optional(string) # "DEFAULT", "IPTABLES", "NONE"
      hosts        = list(string)     # e.g., ["./*", "istio-system/*"]
    })), [])

    # Configuration for the outbound traffic policy.
    outbound_traffic_policy = optional(object({
      mode = string # "REGISTRY_ONLY" or "ALLOW_ANY"
    }))
  }))

  validation {
    condition = alltrue([
      for s in var.sidecars :
      alltrue([
        for ing in s.ingress :
        ing.capture_mode == null || contains(["DEFAULT", "IPTABLES", "NONE"], ing.capture_mode)
      ])
    ])
    error_message = "Invalid 'capture_mode' for a Sidecar ingress listener. Must be one of: 'DEFAULT', 'IPTABLES', 'NONE'."
  }

  validation {
    condition = alltrue([
      for s in var.sidecars :
      alltrue([
        for eg in s.egress :
        eg.capture_mode == null || contains(["DEFAULT", "IPTABLES", "NONE"], eg.capture_mode)
      ])
    ])
    error_message = "Invalid 'capture_mode' for a Sidecar egress listener. Must be one of: 'DEFAULT', 'IPTABLES', 'NONE'."
  }

  validation {
    condition = alltrue([
      for s in var.sidecars :
      s.outbound_traffic_policy == null ||
      contains(["REGISTRY_ONLY", "ALLOW_ANY"], try(s.outbound_traffic_policy.mode, "N/A"))
    ])
    error_message = "Invalid 'mode' for outbound_traffic_policy. Must be one of: 'REGISTRY_ONLY', 'ALLOW_ANY'."
  }
}
