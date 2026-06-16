# variable "project_id" {
#   description = "The GCP project ID where the resources are being managed."
#   type        = string
# }

variable "backend_configs" {
  description = "A list of BackendConfig configurations."
  type = list(object({
    name        = string
    namespace   = optional(string, "istio-system")
    cdn_enabled = optional(bool, false)
    cdn_cache_policy = optional(object({
      include_host         = optional(bool, false)
      include_protocol     = optional(bool, false)
      include_query_string = optional(bool, false)
    }), {})
    cdn_cache_mode   = optional(string)              # e.g., "CACHE_ALL_STATIC", "USE_ORIGIN_HEADERS"
    negative_caching = optional(bool)                # Enable/disable negative caching (default is false if omitted)
    negative_caching_policy = optional(list(object({ # List of HTTP status codes and their TTLs
      code = number
      ttl  = number
    })), []) # Default to an empty list
    iap_enabled              = optional(bool, false)
    iap_secret_name          = optional(string)
    cloudarmor_enabled       = optional(bool, false)
    cloudarmor_custom_policy = optional(string)
    custom_request_headers   = optional(list(string)) # List of custom request headers
    custom_response_headers  = optional(list(string)) # List of custom response headers
    logging_enabled          = optional(bool, false)
    logging_sample_rate      = optional(number) # Sample rate for logging, 0.0 to 1.0
    health_check = optional(object({
      check_interval_sec  = number
      timeout_sec         = number
      healthy_threshold   = number
      unhealthy_threshold = number
      type                = string # e.g., "HTTP", "HTTPS", "TCP", "SSL", "HTTP/2", "TCP_SSL"
      request_path        = optional(string)
      port                = optional(number)
    }))
    session_affinity = optional(object({
      type           = string           # e.g., "CLIENT_IP", "GENERATED_COOKIE", "HTTP_HEADER", "NONE"
      cookie_ttl_sec = optional(number) # Required if type is GENERATED_COOKIE
    }))
    timeout_sec = optional(number, 30)
  }))

  # validation {
  #   condition = alltrue([
  #     for bc in var.backend_configs :
  #     # If iap_enabled is true, then iap_rctoken_aud and iap_httpoption must not be null
  #     !try(bc.iap_enabled,false) || (try(bc.iap_rctoken_aud, null) != null || try(bc.iap_httpoption, null) != null)
  #   ])
  #   error_message = "If 'iap_enabled' is true for any backend configuration, 'iap_rctoken_aud' or 'iap_httpoption' must be provided and not null."
  # }

  # Example usage in a `main.tf` or `terraform.tfvars`:
  # backend_configs = [
  #   {
  #     name                     = "my-app"
  #     namespace                = "default"
  #     cdn_enabled              = true
  #     cdn_cache_policy = {
  #       include_host         = true
  #       include_protocol     = true
  #       include_query_string = false
  #     }
  #     cdn_cache_mode           = "CACHE_ALL_STATIC"
  #     negative_caching         = true
  #     negative_caching_policy = [
  #       { code = 404, ttl = 3600 },
  #       { code = 500, ttl = 100 }
  #     ]
  #     iap_enabled              = true
  #     iap_secret_name          = "iap-backend-config"
  #     iap_rctoken_aud          = "your-audience-string"
  #     iap_httpoption           = "REDIRECT_HTTP_TO_HTTPS"
  #     cloudarmor_enabled       = true
  #     cloudarmor_custom_policy = "my-custom-security-policy"
  #     custom_request_headers   = ["X-My-Request-Header: value"]
  #     custom_response_headers  = ["X-My-Response-Header: value"]
  #     logging_enabled          = true
  #     logging_sample_rate      = 0.5
  #     health_check = {
  #       check_interval_sec  = 5
  #       timeout_sec         = 5
  #       healthy_threshold   = 2
  #       unhealthy_threshold = 2
  #       type                = "HTTP"
  #       request_path        = "/healthz"
  #       port                = 80
  #     }
  #     session_affinity = {
  #       type           = "GENERATED_COOKIE"
  #       cookie_ttl_sec = 86400
  #     }
  #   },
  #   {
  #     name        = "another-app"
  #     namespace   = "prod"
  #     iap_enabled = false
  #     cloudarmor_enabled = true
  #   }
  # ]
}