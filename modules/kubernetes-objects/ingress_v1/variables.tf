variable "ingresses" {
  description = "A list of ingress configurations."
  type = list(object({
    name                 = string
    namespace            = string
    ingress_class        = optional(string, "gce")
    backend_name         = string
    backend_port         = optional(number, 80)
    static_ip_address    = optional(string)
    type                 = optional(string, "global")
    annotations          = optional(map(string), {})
    frontend_config      = optional(string)
    allow_http           = optional(bool, false)
    pre_shared_cert      = optional(string)
    managed_certificates = optional(list(string), [])
  }))
}