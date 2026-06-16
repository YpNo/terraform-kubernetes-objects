variable "virtual_services" {
  description = "A list of Istio VirtualService configurations."
  type = list(object({
    name        = string
    namespace   = string
    labels      = optional(map(string), null)
    annotations = optional(map(string), null)
    hosts       = list(string) # e.g., ["*", "*.example.com", "my-service.my-namespace.svc.cluster.local"]
    gateways    = list(string) # e.g., ["my-gateway", "mesh"]

    # HTTP rules
    http = optional(list(object({
      match = optional(list(object({
        uri           = optional(object({ exact = optional(string), prefix = optional(string), regex = optional(string) }))
        headers       = optional(map(object({ exact = optional(string), prefix = optional(string), regex = optional(string) })), {})
        query_params  = optional(map(object({ exact = optional(string), prefix = optional(string), regex = optional(string) })), {})
        method        = optional(object({ exact = optional(string), prefix = optional(string), regex = optional(string) }))
        source_labels = optional(map(string), {})
        gateways      = optional(list(string), []) # Match requests coming from specified gateways
        port          = optional(number)           # Match on specific port of the gateway
      })), [])

      route = optional(list(object({
        destination = object({
          host   = string
          subset = optional(string)
          port   = optional(number) # Target port on the destination service
        })
        weight = optional(number) # 0-100 for weighted routing
      })), [])

      redirect = optional(object({
        uri           = optional(string) # New URI to redirect to
        authority     = optional(string) # New Authority header
        redirect_code = optional(number) # HTTP status code (e.g., 301, 302)
      }))

      delegate = optional(object({
        name      = string
        namespace = optional(string) # If in different namespace
      }))

      rewrite = optional(object({
        uri       = optional(string)
        authority = optional(string)
        uri_regex_rewrite = optional(object({ # Add this
          match   = string                    # Or optional(string) if it can be empty
          rewrite = string                    # Or optional(string) if it can be empty
        }))
      }))

      timeout = optional(string) # e.g., "5s", "1m"

      retries = optional(object({
        attempts        = number
        per_try_timeout = optional(string)
        retry_on        = optional(string) # e.g., "5xx", "gateway-error", "connect-failure"
      }))

      fault = optional(object({
        delay = optional(object({
          fixed_delay = string # e.g., "5s"
          percentage  = number # 0-100
        }))
        abort = optional(object({
          http_status = number
          percentage  = number # 0-100
        }))
      }))

      mirror = optional(object({
        host   = string
        subset = optional(string)
        port   = optional(number) # Target port on the destination service
      }))
      mirror_percentage = optional(number) # 0-100, if set, mirror is done by percentage

      cors_policy = optional(object({
        allow_origins     = optional(list(object({ exact = optional(string), prefix = optional(string), regex = optional(string) })), [])
        allow_methods     = optional(list(string), []) # e.g., ["GET", "POST"]
        allow_headers     = optional(list(string), [])
        expose_headers    = optional(list(string), [])
        max_age           = optional(string) # e.g., "24h"
        allow_credentials = optional(bool)
      }))

    })), [])

    # TLS rules
    tls = optional(list(object({
      match = optional(list(object({
        sni_hosts = list(string) # SNI hosts to match
        port      = optional(number)
      })), [])
      route = list(object({
        destination = object({
          host   = string
          subset = optional(string)
          port   = optional(number) # Target port on the destination service
        })
        weight = optional(number)
      }))
    })), [])

    # TCP rules
    tcp = optional(list(object({
      match = optional(list(object({
        port          = optional(number)
        sni_hosts     = optional(list(string), [])
        source_labels = optional(map(string), {})
      })), [])
      route = list(object({
        destination = object({
          host   = string
          subset = optional(string)
          port   = optional(number) # Target port on the destination service
        })
        weight = optional(number)
      }))
    })), [])
  }))

  validation {
    condition = alltrue([
      for vs_item in var.virtual_services :
      alltrue([
        for http_rule in vs_item.http :
        # CORRECTED VALIDATION:
        # Ensure only one of 'route', 'redirect', or 'delegate' is specified as the primary routing action.
        # 'rewrite' can coexist with 'route', 'fault', 'mirror', 'timeout', 'retries', 'cors_policy'.
        length(compact([
          length(http_rule.route) > 0 ? true : null, # Check if 'route' list is not empty
          http_rule.redirect != null ? true : null,  # Check if 'redirect' object is defined
          http_rule.delegate != null ? true : null   # Check if 'delegate' object is defined
        ])) <= 1                                     # Allows 0 (no primary action, e.g., if only a fault is defined) or 1 primary action.
      ])
    ])
    error_message = "For each HTTP rule, only one of 'route', 'redirect', or 'delegate' can be specified as the primary routing action. 'rewrite' is a transformation and can be used with 'route'."
  }

  validation {
    condition = alltrue([
      for vs_item in var.virtual_services :
      alltrue([
        for http_rule in vs_item.http :
        # Validate that if mirror is set, mirror_percentage is also set
        (http_rule.mirror != null) == (http_rule.mirror_percentage != null)
      ])
    ])
    error_message = "If 'mirror' is specified, 'mirror_percentage' must also be specified, and vice-versa, for HTTP rules."
  }

  # Example usage in a `main.tf` or `terraform.tfvars`:
  # virtual_services = [
  #   {
  #     name        = "httpbin-vs"
  #     namespace   = "default"
  #     hosts       = ["httpbin.example.com"]
  #     gateways    = ["httpbin-gateway"] # Assumes a Gateway named httpbin-gateway exists
  #     http = [
  #       {
  #         match = [
  #           {
  #             uri = { prefix = "/status" }
  #           }
  #         ]
  #         route = [
  #           {
  #             destination = {
  #               host   = "httpbin" # Service name in the same namespace
  #               port   = 80
  #             }
  #           }
  #         ]
  #       },
  #       {
  #         match = [
  #           {
  #             uri = { exact = "/headers" }
  #             headers = {
  #               "x-user-id" = { exact = "123" }
  #             }
  #           }
  #         ]
  #         rewrite = {
  #           uri = "/new-headers-path"
  #         }
  #       },
  #       {
  #         match = [
  #           {
  #             uri = { prefix = "/" }
  #           }
  #         ]
  #         route = [
  #           {
  #             destination = { host = "httpbin-v1", port = 80 },
  #             weight      = 80
  #           },
  #           {
  #             destination = { host = "httpbin-v2", port = 80 },
  #             weight      = 20
  #           }
  #         ]
  #         timeout = "10s"
  #         retries = {
  #           attempts = 3
  #           retry_on = "5xx"
  #         }
  #         fault = {
  #           abort = { http_status = 503, percentage = 10 } # 10% of requests abort with 503
  #         }
  #         mirror = {
  #           host = "httpbin-mirror",
  #           port = 80
  #         }
  #         mirror_percentage = 100 # Mirror 100% of traffic
  #       }
  #     ]
  #   },
  #   {
  #     name        = "tls-passthrough-vs"
  #     namespace   = "default"
  #     hosts       = ["my-secure-service.example.com"]
  #     gateways    = ["my-tls-gateway"]
  #     tls = [
  #       {
  #         match = [{ sni_hosts = ["my-secure-service.example.com"] }]
  #         route = [{ destination = { host = "my-secure-service", port = 443 } }]
  #       }
  #     ]
  #   },
  #   {
  #     name        = "tcp-proxy-vs"
  #     namespace   = "default"
  #     hosts       = ["my-tcp-service.example.com"]
  #     gateways    = ["my-tcp-gateway"]
  #     tcp = [
  #       {
  #         match = [{ port = 9000 }]
  #         route = [{ destination = { host = "my-tcp-backend", port = 9000 } }]
  #       }
  #     ]
  #   }
  # ]
}
