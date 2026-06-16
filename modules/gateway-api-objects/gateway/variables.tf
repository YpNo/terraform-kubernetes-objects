variable "gateways" {
  description = "A list of Gateway objects to create."
  type = list(object({
    name               = string
    namespace          = string
    labels             = optional(map(string))
    annotations        = optional(map(string))
    gateway_class_name = string
    listeners = list(object({
      name     = string
      protocol = string # e.g., "HTTP", "HTTPS", "TCP", "TLS"
      port     = number
      hostname = optional(string)
      tls = optional(object({
        mode = optional(string, "Terminate") # "Terminate" or "Passthrough"
        certificate_refs = list(object({
          group     = optional(string, "")
          kind      = optional(string, "Secret")
          name      = string
          namespace = optional(string)
        }))
      }))
      allowed_routes = optional(object({
        namespaces = optional(object({
          from = optional(string, "Same") # "All", "Same", "Selector"
          selector = optional(object({
            match_labels = map(string)
          }))
        }))
        kinds = optional(list(object({
          group = optional(string, "gateway.networking.k8s.io")
          kind  = string # e.g., "HTTPRoute", "TCPRoute"
        })), [{ kind = "HTTPRoute" }])
      }))
    }))
    addresses = optional(list(object({
      type  = string # "NamedAddress" or "IPAddress"
      value = string
    })), [])
  }))
  default = []
}
