# istio-telemetry/variables.tf

variable "telemetries" {
  description = "A list of Istio Telemetry configurations."
  type = list(object({
    name        = string
    namespace   = optional(string)
    labels      = optional(map(string), {})
    annotations = optional(map(string), {})
    selector    = optional(map(string))

    metrics = optional(list(object({
      providers = optional(list(string), [])
      overrides = optional(list(object({
        name = string
        tags = map(string)
      })), [])
      reporting_duration = optional(string)
      empty_duration     = optional(string)
      disabled           = optional(bool)
    })), [])

    access_logging = optional(list(object({
      providers     = optional(list(string), [])
      disabled      = optional(bool)
      custom_format = optional(string)
      filter        = optional(object({ expression = string }))
      encoding      = optional(string)
    })), [])

    tracing = optional(list(object({
      providers = optional(list(string), [])
      sampling  = optional(object({ percent = number }))

      # CORRECTION ICI : Définition explicite de l'objet au lieu de local.custom_tag_value_type
      custom_tags = optional(map(object({
        literal     = optional(object({ value = string }))
        header      = optional(object({ name = string, omit_if_not_present = optional(bool) }))
        environment = optional(object({ name = string, omit_if_not_present = optional(bool) }))
      })), {})

      match = optional(object({
        mode    = optional(string)
        port    = optional(number)
        headers = optional(map(string), {})
      }))
      disabled = optional(bool)
    })), [])
  }))

  validation {
    condition = alltrue([
      for tm_item in var.telemetries :
      (tm_item.name != "default") || (tm_item.namespace == null)
    ])
    error_message = "If 'name' is 'default' for a Telemetry policy, 'namespace' must not be set (as it denotes a mesh-wide policy)."
  }

  validation {
    condition = alltrue([
      for tm_item in var.telemetries :
      (tm_item.namespace != null) || (tm_item.name == "default")
    ])
    error_message = "If 'namespace' is not set for a Telemetry policy, 'name' must be 'default' (as it denotes a mesh-wide policy)."
  }

  validation {
    condition = alltrue([
      for tm_item in var.telemetries :
      alltrue([
        for al in try(tm_item.access_logging, []) :
        # Si al.encoding est null, on teste "JSON" (qui est valide), sinon on teste la vraie valeur
        contains(["JSON", "TEXT"], coalesce(al.encoding, "JSON"))
      ])
    ])
    error_message = "Invalid 'encoding' for Telemetry access logging. Must be 'JSON' or 'TEXT'."
  }

  validation {
    condition = alltrue([
      for tm_item in var.telemetries :
      alltrue([
        for trace in try(tm_item.tracing, []) :
        alltrue([
          for key, tag in trace.custom_tags :
          # Ensure exactly one of literal, header, or environment is provided for each custom tag
          (tag.literal != null && tag.header == null && tag.environment == null) ||
          (tag.literal == null && tag.header != null && tag.environment == null) ||
          (tag.literal == null && tag.header == null && tag.environment != null)
        ])
      ])
    ])
    error_message = "Each 'custom_tag' in Telemetry tracing must specify exactly one of 'literal', 'header', or 'environment'."
  }

  validation {
    condition = alltrue([
      for tm_item in var.telemetries :
      alltrue([
        for trace in try(tm_item.tracing, []) :
        trace.match == null || trace.match.mode == null || contains(["CLIENT", "SERVER"], trace.match.mode)
      ])
    ])
    error_message = "Invalid 'mode' for Telemetry tracing match. Must be 'CLIENT' or 'SERVER'."
  }

  # Example usage in a `main.tf` or `terraform.tfvars`:
  # telemetries = [
  #   {
  #     # Mesh-wide policy: Disable default metrics, enable access logging with custom format
  #     name      = "default"
  #     metrics = [{ disabled = true }] # Disable default metrics
  #     access_logging = [
  #       {
  #         providers    = ["envoy_accesslog"]
  #         encoding     = "JSON"
  #         custom_format = jsonencode({ # Example custom format
  #           "start_time"         = "%START_TIME%"
  #           "request_method"     = "%REQ(:METHOD)%"
  #           "request_path"       = "%REQ(:PATH)%"
  #           "response_code"      = "%RESPONSE_CODE%"
  #           "duration"           = "%DURATION%"
  #           "bytes_received"     = "%BYTES_RECEIVED%"
  #           "bytes_sent"         = "%BYTES_SENT%"
  #           "upstream_host"      = "%UPSTREAM_HOST%"
  #           "x_forwarded_for"    = "%REQ(X-FORWARDED-FOR)%"
  #           "response_flags"     = "%RESPONSE_FLAGS%"
  #           "route_name"         = "%ROUTE_NAME%"
  #           "downstream_remote_address" = "%DOWNSTREAM_REMOTE_ADDRESS%"
  #           "connection_termination_details" = "%CONNECTION_TERMINATION_DETAILS%"
  #         })
  #         filter = {
  #           expression = "response.code >= 400 || response.code == 0"
  #         }
  #       }
  #     ]
  #     tracing = [
  #       { disabled = true } # Disable mesh-wide tracing if not needed
  #     ]
  #   },
  #   {
  #     # Namespace-wide policy: Enable tracing for all services in 'my-app-namespace'
  #     name      = "default"
  #     namespace = "my-app-namespace"
  #     tracing = [
  #       {
  #         providers = ["zipkin"]
  #         sampling  = { percent = 100 } # 100% sampling for this namespace
  #         custom_tags = {
  #           "user_id" = { header = { name = "x-user-id", omit_if_not_present = true } }
  #           "env"     = { literal = { value = "production" } }
  #           "service_version" = { environment = { name = "SERVICE_VERSION", omit_if_not_present = false } }
  #         }
  #       }
  #     ]
  #   },
  #   {
  #     # Workload-specific policy: Metrics overrides for a specific service
  #     name      = "my-service-telemetry"
  #     namespace = "my-app-namespace"
  #     selector  = { "app" = "my-service" }
  #     metrics = [
  #       {
  #         providers = ["prometheus"]
  #         overrides = [
  #           {
  #             name = "requests_total"
  #             tags = { "cluster_region" = "us-west-1" }
  #           }
  #         ]
  #       }
  #     ]
  #   }
  # ]
}
