variable "http_routes" {
  description = "A list of HTTPRoute objects to create."
  type = list(object({
    name        = string
    namespace   = string
    labels      = optional(map(string))
    annotations = optional(map(string))
    parent_refs = list(object({
      name         = string
      namespace    = optional(string)
      section_name = optional(string)
    }))
    hostnames = optional(list(string))
    rules = list(object({
      matches = optional(list(object({
        path = optional(object({
          type  = optional(string, "PathPrefix") # Exact, PathPrefix, RegularExpression
          value = optional(string, "/")
        }))
        headers = optional(list(object({
          type  = optional(string, "Exact") # Exact, RegularExpression
          name  = string
          value = string
        })), [])
        query_params = optional(list(object({
          type  = optional(string, "Exact") # Exact, RegularExpression
          name  = string
          value = string
        })), [])
        method = optional(string) # e.g., "GET", "POST"
      })), [{ path = { type = "PathPrefix", value = "/" } }])
      filters = optional(list(object({
        type = string # "RequestHeaderModifier", "RequestRedirect"
        request_header_modifier = optional(object({
          set    = optional(list(object({ name = string, value = string })), [])
          add    = optional(list(object({ name = string, value = string })), [])
          remove = optional(list(string), [])
        }))
        request_redirect = optional(object({
          scheme   = optional(string)
          hostname = optional(string)
          path = optional(object({
            type                 = string # "ReplaceFullPath", "ReplacePrefixMatch"
            replace_full_path    = optional(string)
            replace_prefix_match = optional(string)
          }))
          port        = optional(number)
          status_code = optional(number, 302)
        }))
      })), [])
      backend_refs = list(object({
        name      = string
        namespace = optional(string)
        port      = number
        weight    = optional(number, 1)
      }))
    }))
  }))
  default = []
}
