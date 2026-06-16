variable "reference_grants" {
  description = "A list of ReferenceGrant objects to create."
  type = list(object({
    name        = string
    namespace   = string
    labels      = optional(map(string))
    annotations = optional(map(string))
    from = list(object({
      group     = string # e.g., "gateway.networking.k8s.io"
      kind      = string # e.g., "Gateway"
      namespace = string
    }))
    to = list(object({
      group = string # e.g., "" (core)
      kind  = string # e.g., "Secret"
      name  = optional(string)
    }))
  }))
  default = []
}
