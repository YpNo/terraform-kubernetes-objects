variable "gcp_gateway_policies" {
  description = "A list of GCPGatewayPolicy configurations."
  type = list(object({
    name        = string
    namespace   = optional(string, "istio-system")
    labels      = optional(map(string))
    annotations = optional(map(string))
    # spec.default - the LoadBalancer policy configuration applied to the Gateway.
    allow_global_access = optional(bool)
    ssl_policy          = optional(string) # name of the SSL policy
    region              = optional(string) # load balancer region for Multi-cluster Gateway
    # spec.targetRef - the Gateway the policy attaches to.
    target_ref = object({
      group     = optional(string, "gateway.networking.k8s.io")
      kind      = optional(string, "Gateway")
      name      = string
      namespace = optional(string)
    })
  }))
  default = []
}
