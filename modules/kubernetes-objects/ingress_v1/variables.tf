variable "ingresses" {
  description = "A list of Ingress configurations (GKE-oriented, but usable with any Ingress controller)."
  type = list(object({
    name        = string
    namespace   = string
    labels      = optional(map(string), {})
    annotations = optional(map(string), {})

    # spec.ingressClassName (modern). GKE typically selects the controller via the
    # `ingress_class` annotation shortcut below instead.
    ingress_class_name = optional(string)

    # Default backend (optional). Traffic not matching any rule goes here.
    backend_name = optional(string)
    backend_port = optional(number, 80)

    # Host / path routing rules.
    rules = optional(list(object({
      host = optional(string)
      paths = list(object({
        path                = optional(string, "/")
        path_type           = optional(string, "Prefix") # "Prefix", "Exact", "ImplementationSpecific"
        service_name        = string
        service_port_number = optional(number)
        service_port_name   = optional(string)
      }))
    })), [])

    # TLS termination.
    tls = optional(list(object({
      hosts       = optional(list(string), [])
      secret_name = optional(string)
    })), [])

    # --- GKE annotation shortcuts (merged into metadata.annotations) ---
    ingress_class        = optional(string, "gce")    # -> kubernetes.io/ingress.class
    allow_http           = optional(bool, false)      # -> kubernetes.io/ingress.allow-http
    static_ip_address    = optional(string)           # -> global/regional static IP annotation
    type                 = optional(string, "global") # "global" or "regional" (selects the static IP annotation)
    frontend_config      = optional(string)           # -> networking.gke.io/v1beta1.FrontendConfig
    pre_shared_cert      = optional(string)           # -> ingress.gcp.kubernetes.io/pre-shared-cert
    managed_certificates = optional(list(string), []) # -> networking.gke.io/managed-certificates
  }))

  validation {
    condition = alltrue([
      for i in var.ingresses : alltrue([
        for r in i.rules : alltrue([
          for p in r.paths : contains(["Prefix", "Exact", "ImplementationSpecific"], p.path_type)
        ])
      ])
    ])
    error_message = "Invalid 'path_type'. Must be 'Prefix', 'Exact' or 'ImplementationSpecific'."
  }

  validation {
    condition = alltrue([
      for i in var.ingresses : contains(["global", "regional"], i.type)
    ])
    error_message = "Invalid 'type'. Must be 'global' or 'regional'."
  }
}
