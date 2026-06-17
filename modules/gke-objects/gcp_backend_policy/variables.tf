variable "gcp_backend_policies" {
  description = "A list of GCPBackendPolicy configurations."
  type = list(object({
    name        = string
    namespace   = optional(string, "istio-system")
    labels      = optional(map(string))
    annotations = optional(map(string))
    # spec.default - the LoadBalancer policy configuration applied to the backend.
    backend_preference    = optional(string) # DEFAULT | PREFERRED
    security_policy       = optional(string) # Cloud Armor security policy name
    timeout_sec           = optional(number) # Backend service timeout, 1-2147483647
    max_rate_per_endpoint = optional(number) # 1-1000000000
    logging = optional(object({
      enabled     = bool
      sample_rate = optional(number) # 0-1000000
    }))
    session_affinity = optional(object({
      type           = string           # CLIENT_IP, CLIENT_IP_PORT_PROTO, CLIENT_IP_PROTO, GENERATED_COOKIE, HEADER_FIELD, HTTP_COOKIE, NONE
      cookie_ttl_sec = optional(number) # 0-1209600
    }))
    connection_draining = optional(object({
      draining_timeout_sec = number # 0-3600
    }))
    iap = optional(object({
      enabled                   = bool
      client_id                 = optional(string)
      oauth2_client_secret_name = optional(string) # name of the Kubernetes Secret holding the OAuth2 client secret
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
