variable "gateway_policies" {
  description = "A list of Gateway Policy objects to create."
  type = list(object({
    name        = string
    namespace   = string
    labels      = optional(map(string))
    api_version = optional(string, "networking.gke.io/v1")
    kind        = string # e.g., "GCPBackendPolicy", "HealthCheckPolicy"

    target_ref = object({
      group = optional(string, "") # Core group for "Service"
      kind  = string               # e.g., "Service", "Gateway"
      name  = string
    })

    policy_spec = any # Flexible spec for the specific policy
  }))
  default = []
}
