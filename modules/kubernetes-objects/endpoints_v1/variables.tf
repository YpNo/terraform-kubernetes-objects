variable "endpoints" {
  description = "A list of Kubernetes Endpoints configurations. An Endpoints resource is namespaced and exposes the IP addresses and ports that implement a Service, typically used for Services without selectors."
  type = list(object({
    name        = string
    namespace   = string
    labels      = optional(map(string), {}) # Labels for the Endpoints metadata
    annotations = optional(map(string), {}) # Annotations for the Endpoints metadata

    # Each subset groups a set of addresses with the ports they expose.
    subsets = optional(list(object({
      # address lists IPs that are ready to receive traffic.
      address = optional(list(object({
        ip        = string           # Must not be loopback, link-local, or link-local multicast.
        hostname  = optional(string) # The hostname of this endpoint.
        node_name = optional(string) # Node hosting this endpoint.
      })), [])
      # not_ready_address lists IPs that are not yet ready (e.g. still starting or failing checks).
      not_ready_address = optional(list(object({
        ip        = string
        hostname  = optional(string)
        node_name = optional(string)
      })), [])
      # port lists the ports exposed by the addresses in this subset.
      port = optional(list(object({
        port     = number                  # The port number exposed by this endpoint.
        name     = optional(string)        # DNS_LABEL name; optional if only one port is defined.
        protocol = optional(string, "TCP") # "TCP" or "UDP". Defaults to "TCP".
      })), [])
    })), [])
  }))
  default = []

  validation {
    condition = alltrue([
      for e in var.endpoints :
      alltrue([
        for s in e.subsets :
        alltrue([
          for p in s.port : contains(["TCP", "UDP"], p.protocol)
        ])
      ])
    ])
    error_message = "Invalid 'subsets.port.protocol'. Must be 'TCP' or 'UDP'."
  }

  # Example usage in a `main.tf` or `terraform.tfvars`:
  # endpoints = [
  #   {
  #     name      = "external-db"
  #     namespace = "default"
  #     subsets = [
  #       {
  #         address = [{ ip = "10.0.0.4" }, { ip = "10.0.0.5" }]
  #         port    = [{ name = "https", port = 443, protocol = "TCP" }]
  #       }
  #     ]
  #   }
  # ]
}
