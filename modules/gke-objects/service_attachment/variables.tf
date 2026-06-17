variable "service_attachments" {
  description = "A list of ServiceAttachment configurations for publishing services via Private Service Connect."
  type = list(object({
    name        = string
    namespace   = optional(string, "istio-system")
    labels      = optional(map(string))
    annotations = optional(map(string))
    # spec.connectionPreference - how consumers connect: ACCEPT_AUTOMATIC | ACCEPT_MANUAL.
    connection_preference = string
    # spec.natSubnets - subnetwork resource names used for Private Service Connect source NAT.
    nat_subnets = list(string)
    # spec.proxyProtocol - expose consumer source IP and PSC connection ID to requests.
    proxy_protocol = optional(bool)
    # spec.consumerAllowList - consumers allowed to connect (used with ACCEPT_MANUAL).
    consumer_allow_list = optional(list(object({
      project          = string           # consumer project ID or number
      connection_limit = optional(number) # max connections from the project
    })))
    # spec.consumerRejectList - consumer project IDs or numbers denied connections.
    consumer_reject_list = optional(list(string))
    # spec.resourceRef - the Service being exposed.
    resource_ref = object({
      kind      = optional(string, "Service")
      name      = string
      api_group = optional(string)
    })
  }))
  default = []
}
