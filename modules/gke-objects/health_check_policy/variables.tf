variable "health_check_policies" {
  description = "A list of HealthCheckPolicy configurations."
  type = list(object({
    name        = string
    namespace   = optional(string, "istio-system")
    labels      = optional(map(string))
    annotations = optional(map(string))
    # spec.default - the HealthCheck configuration applied to the BackendService.
    check_interval_sec  = optional(number) # 1-300, default 5
    timeout_sec         = optional(number) # 1-300, default 5
    healthy_threshold   = optional(number) # 1-10, default 2
    unhealthy_threshold = optional(number) # 1-10, default 2
    log_config = optional(object({
      enabled = bool
    }))
    # spec.default.config - union per protocol; set "type" plus the matching block.
    config = object({
      type = string # TCP | HTTP | HTTPS | HTTP2 | GRPC
      http_health_check = optional(object({
        port               = optional(number)
        port_name          = optional(string)
        port_specification = optional(string) # USE_FIXED_PORT | USE_NAMED_PORT | USE_SERVING_PORT
        request_path       = optional(string)
        host               = optional(string)
        response           = optional(string)
        proxy_header       = optional(string) # NONE | PROXY_V1
      }))
      https_health_check = optional(object({
        port               = optional(number)
        port_name          = optional(string)
        port_specification = optional(string)
        request_path       = optional(string)
        host               = optional(string)
        response           = optional(string)
        proxy_header       = optional(string)
      }))
      http2_health_check = optional(object({
        port               = optional(number)
        port_name          = optional(string)
        port_specification = optional(string)
        request_path       = optional(string)
        host               = optional(string)
        response           = optional(string)
        proxy_header       = optional(string)
      }))
      grpc_health_check = optional(object({
        port               = optional(number)
        port_name          = optional(string)
        port_specification = optional(string)
        grpc_service_name  = optional(string)
      }))
      tcp_health_check = optional(object({
        port               = optional(number)
        port_name          = optional(string)
        port_specification = optional(string)
        request            = optional(string)
        response           = optional(string)
        proxy_header       = optional(string)
      }))
    })
    # spec.targetRef - the resource the policy attaches to.
    target_ref = object({
      group     = optional(string, "")
      kind      = optional(string, "Service")
      name      = string
      namespace = optional(string)
    })
  }))
  default = []
}
