variable "gcp_traffic_distribution_policies" {
  description = "A list of GCPTrafficDistributionPolicy configurations."
  type = list(object({
    name        = string
    namespace   = optional(string, "istio-system")
    labels      = optional(map(string))
    annotations = optional(map(string))
    # spec.default - the traffic distribution configuration applied to the targets.
    default = optional(object({
      service_lb_algorithm  = optional(string) # SPRAY_TO_REGION | WATERFALL_BY_ZONE | WATERFALL_BY_REGION
      locality_lb_algorithm = optional(string) # ROUND_ROBIN | LEAST_REQUEST | RING_HASH | RANDOM | ORIGINAL_DESTINATION | MAGLEV | WEIGHTED_ROUND_ROBIN
      auto_capacity_drain = optional(object({
        enable_auto_capacity_drain = bool
      }))
      failover_config = optional(object({
        failover_health_threshold = number # 0-100
      }))
    }))
    # spec.targetRefs - the Services the policy attaches to (1-16, Service only).
    target_refs = list(object({
      group = optional(string, "")
      kind  = optional(string, "Service")
      name  = string
    }))
  }))
  default = []
}
