variable "network_policies" {
  description = "A list of Kubernetes NetworkPolicy configurations."
  type = list(object({
    name        = string
    namespace   = string
    labels      = optional(map(string), {}) # Labels for the NetworkPolicy metadata
    annotations = optional(map(string), {}) # Annotations for the NetworkPolicy metadata

    # podSelector selects the pods to which this NetworkPolicy applies.
    # An empty selector ({}) matches all pods in the namespace.
    pod_selector = optional(object({
      match_labels = optional(map(string), {})
      match_expressions = optional(list(object({
        key      = string
        operator = string                     # "In", "NotIn", "Exists", "DoesNotExist"
        values   = optional(list(string), []) # Required non-empty for In/NotIn; empty for Exists/DoesNotExist
      })), [])
    }), {})

    # Valid options: ["Ingress"], ["Egress"], or ["Ingress", "Egress"].
    policy_types = optional(list(string), [])

    ingress = optional(list(object({
      ports = optional(list(object({
        port     = optional(string) # Numerical or named port
        protocol = optional(string) # "TCP", "UDP", "SCTP" (defaults to TCP)
        end_port = optional(number) # End of a port range; requires a numeric port
      })), [])
      from = optional(list(object({
        pod_selector = optional(object({
          match_labels = optional(map(string), {})
          match_expressions = optional(list(object({
            key      = string
            operator = string
            values   = optional(list(string), [])
          })), [])
        }))
        namespace_selector = optional(object({
          match_labels = optional(map(string), {})
          match_expressions = optional(list(object({
            key      = string
            operator = string
            values   = optional(list(string), [])
          })), [])
        }))
        ip_block = optional(object({
          cidr   = string                     # e.g. "10.0.0.0/8"
          except = optional(list(string), []) # CIDRs excluded from the block
        }))
      })), [])
    })), [])

    egress = optional(list(object({
      ports = optional(list(object({
        port     = optional(string)
        protocol = optional(string)
        end_port = optional(number)
      })), [])
      to = optional(list(object({
        pod_selector = optional(object({
          match_labels = optional(map(string), {})
          match_expressions = optional(list(object({
            key      = string
            operator = string
            values   = optional(list(string), [])
          })), [])
        }))
        namespace_selector = optional(object({
          match_labels = optional(map(string), {})
          match_expressions = optional(list(object({
            key      = string
            operator = string
            values   = optional(list(string), [])
          })), [])
        }))
        ip_block = optional(object({
          cidr   = string
          except = optional(list(string), [])
        }))
      })), [])
    })), [])
  }))

  validation {
    condition = alltrue([
      for np in var.network_policies :
      alltrue([
        for pt in np.policy_types : contains(["Ingress", "Egress"], pt)
      ])
    ])
    error_message = "Invalid 'policy_types' entry. Each value must be 'Ingress' or 'Egress'."
  }

  validation {
    condition = alltrue([
      for np in var.network_policies :
      alltrue([
        for me in np.pod_selector.match_expressions :
        contains(["In", "NotIn", "Exists", "DoesNotExist"], me.operator)
      ])
    ])
    error_message = "Invalid 'pod_selector.match_expressions.operator'. Must be 'In', 'NotIn', 'Exists' or 'DoesNotExist'."
  }

  # Example usage in a `main.tf` or `terraform.tfvars`:
  # network_policies = [
  #   {
  #     name      = "allow-frontend"
  #     namespace = "default"
  #     pod_selector = {
  #       match_labels = { app = "backend" }
  #     }
  #     policy_types = ["Ingress", "Egress"]
  #     ingress = [
  #       {
  #         ports = [{ port = "8080", protocol = "TCP" }]
  #         from = [
  #           { pod_selector = { match_labels = { app = "frontend" } } },
  #           { namespace_selector = { match_labels = { name = "default" } } },
  #           { ip_block = { cidr = "10.0.0.0/8", except = ["10.0.0.0/24"] } }
  #         ]
  #       }
  #     ]
  #     egress = [
  #       {
  #         ports = [{ port = "53", protocol = "UDP" }]
  #         to    = [{ namespace_selector = {} }]
  #       }
  #     ]
  #   }
  # ]
}
