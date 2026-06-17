variable "gcp_session_affinity_policies" {
  description = "A list of GCPSessionAffinityPolicy configurations."
  type = list(object({
    name        = string
    namespace   = optional(string, "istio-system")
    labels      = optional(map(string))
    annotations = optional(map(string))
    # spec.statefulGeneratedCookie - stateful cookie-based session affinity.
    stateful_generated_cookie = optional(object({
      cookie_ttl_seconds = number # 1-86400
    }))
    # spec.targetRef - the resource the policy attaches to.
    target_ref = object({
      group     = optional(string, "")
      kind      = optional(string, "Service")
      name      = string
      namespace = optional(string)
    })
  }))
  default = []
}
