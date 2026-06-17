variable "tcp_routes" {
  description = "A list of TCPRoute objects to create."
  type = list(object({
    name        = string
    namespace   = string
    labels      = optional(map(string))
    annotations = optional(map(string))
    parent_refs = list(object({
      group        = optional(string)
      kind         = optional(string)
      name         = string
      namespace    = optional(string)
      section_name = optional(string)
      port         = optional(number)
    }))
    rules = list(object({
      name = optional(string)
      backend_refs = optional(list(object({
        group     = optional(string)
        kind      = optional(string)
        name      = string
        namespace = optional(string)
        port      = number
        weight    = optional(number, 1)
      })), [])
    }))
  }))
  default = []
}
