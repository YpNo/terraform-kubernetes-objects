variable "gcp_session_affinity_filters" {
  description = "A list of GCPSessionAffinityFilter configurations. Referenced by an HTTPRoute extensionRef filter rather than attached via targetRef."
  type = list(object({
    name        = string
    namespace   = optional(string, "istio-system")
    labels      = optional(map(string))
    annotations = optional(map(string))
    # spec.statefulGeneratedCookie - stateful cookie-based session affinity.
    stateful_generated_cookie = object({
      cookie_ttl_seconds = number # 1-86400
    })
  }))
  default = []
}
