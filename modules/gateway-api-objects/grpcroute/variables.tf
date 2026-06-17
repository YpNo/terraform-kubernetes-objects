variable "grpc_routes" {
  description = "A list of GRPCRoute objects to create."
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
    hostnames = optional(list(string))
    rules = list(object({
      matches = optional(list(object({
        method = optional(object({
          type    = optional(string, "Exact") # "Exact", "RegularExpression"
          service = optional(string)
          method  = optional(string)
        }))
        headers = optional(list(object({
          type  = optional(string, "Exact") # "Exact", "RegularExpression"
          name  = string
          value = string
        })), [])
      })), [])
      filters = optional(list(object({
        type = string # "RequestHeaderModifier", "ResponseHeaderModifier", "RequestMirror"
        request_header_modifier = optional(object({
          set    = optional(list(object({ name = string, value = string })), [])
          add    = optional(list(object({ name = string, value = string })), [])
          remove = optional(list(string), [])
        }))
        response_header_modifier = optional(object({
          set    = optional(list(object({ name = string, value = string })), [])
          add    = optional(list(object({ name = string, value = string })), [])
          remove = optional(list(string), [])
        }))
        request_mirror = optional(object({
          backend_ref = object({
            group     = optional(string)
            kind      = optional(string)
            name      = string
            namespace = optional(string)
            port      = optional(number)
          })
          percent = optional(number)
          fraction = optional(object({
            numerator   = number
            denominator = optional(number, 100)
          }))
        }))
      })), [])
      backend_refs = optional(list(object({
        name      = string
        namespace = optional(string)
        port      = number
        weight    = optional(number, 1)
      })), [])
    }))
  }))
  default = []
}
