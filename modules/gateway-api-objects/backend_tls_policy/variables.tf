variable "backend_tls_policies" {
  description = "A list of BackendTLSPolicy objects to create."
  type = list(object({
    name        = string
    namespace   = string
    labels      = optional(map(string))
    annotations = optional(map(string))
    target_refs = list(object({
      group        = optional(string, "")
      kind         = optional(string, "Service")
      name         = string
      section_name = optional(string)
    }))
    validation = object({
      ca_certificate_refs = optional(list(object({
        group = optional(string, "")
        kind  = optional(string, "ConfigMap")
        name  = string
      })), [])
      well_known_ca_certificates = optional(string) # "System"
      hostname                   = string
      subject_alt_names = optional(list(object({
        type     = string # "Hostname" or "URI"
        hostname = optional(string)
        uri      = optional(string)
      })), [])
    })
    options = optional(map(string))
  }))
  default = []
}
