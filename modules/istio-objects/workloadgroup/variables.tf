variable "workload_groups" {
  description = "A list of Istio WorkloadGroup configurations."
  type = list(object({
    name        = string
    namespace   = string
    labels      = optional(map(string))
    annotations = optional(map(string))

    # Metadata propagated to each auto-registered WorkloadEntry.
    template_metadata = optional(object({
      labels      = optional(map(string), {})
      annotations = optional(map(string), {})
    }))

    # Template describing the WorkloadEntry generated for members of the group.
    template = object({
      address         = optional(string)
      ports           = optional(map(number), {})
      service_account = optional(string)
      network         = optional(string)
      locality        = optional(string)
      weight          = optional(number)
      labels          = optional(map(string), {})
    })

    # Readiness probe used to determine member health.
    probe = optional(object({
      initial_delay_seconds = optional(number)
      timeout_seconds       = optional(number)
      period_seconds        = optional(number)
      success_threshold     = optional(number)
      failure_threshold     = optional(number)

      http_get = optional(object({
        path   = optional(string)
        port   = number
        host   = optional(string)
        scheme = optional(string)
        http_headers = optional(list(object({
          name  = string
          value = string
        })), [])
      }))

      tcp_socket = optional(object({
        host = optional(string)
        port = number
      }))

      exec = optional(object({
        command = list(string)
      }))

      grpc = optional(object({
        port    = number
        service = optional(string)
      }))
    }))
  }))
}
