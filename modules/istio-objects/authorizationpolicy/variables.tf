variable "authorization_policies" {
  description = "A list of Istio AuthorizationPolicy configurations."
  type = list(object({
    name        = string
    namespace   = string
    labels      = optional(map(string), {})
    annotations = optional(map(string), {})

    selector = optional(map(string)) # Labels to select target workloads (pods)

    action = optional(string, "ALLOW") # "ALLOW", "DENY", "AUDIT", "CUSTOM"

    rules = optional(list(object({                      # Logical OR of rules
      from = optional(list(object({                     # Logical AND of sources
        source_principals  = optional(list(string), []) # e.g., ["cluster.local/ns/default/sa/my-sa"]
        request_principals = optional(list(string), []) # e.g., ["iss@example.com/sub"] (JWT claims)
        namespaces         = optional(list(string), []) # e.g., ["default", "kube-system"]
        ip_blocks          = optional(list(string), []) # CIDR blocks (e.g., ["192.168.1.0/24"])
        remote_ip_blocks   = optional(list(string), []) # CIDR blocks from X-Forwarded-For

        not_source_principals  = optional(list(string), [])
        not_request_principals = optional(list(string), [])
        not_namespaces         = optional(list(string), [])
        not_ip_blocks          = optional(list(string), [])
        not_remote_ip_blocks   = optional(list(string), [])
      })), [])

      to = optional(list(object({ # Logical AND of operations
        # ADDED: hosts and not_hosts are required by the provider for the 'operation' block
        hosts   = optional(list(string), []) # Added
        methods = optional(list(string), []) # e.g., ["GET", "POST", "*"]
        paths   = optional(list(string), []) # e.g., ["/api/*", "/login"]
        ports   = optional(list(string), []) # e.g., ["80", "443"]

        not_hosts   = optional(list(string), []) # Added
        not_methods = optional(list(string), [])
        not_paths   = optional(list(string), [])
        not_ports   = optional(list(string), [])
      })), [])

      when = optional(list(object({             # Logical AND of conditions
        key        = string                     # e.g., "request.headers[x-custom-header]", "destination.labels[app]"
        values     = optional(list(string), []) # e.g., ["value1", "value2"]
        not_values = optional(list(string), [])
      })), [])
    })), [])
  }))

  validation {
    condition = alltrue([
      for ap_item in var.authorization_policies :
      ap_item.action == null || contains(["ALLOW", "DENY", "AUDIT", "CUSTOM"], ap_item.action)
    ])
    error_message = "Invalid 'action' for AuthorizationPolicy. Must be one of: 'ALLOW', 'DENY', 'AUDIT', 'CUSTOM'."
  }

  validation {
    condition = alltrue([
      for ap_item in var.authorization_policies :
      alltrue([
        for rule in try(ap_item.rules, []) :
        alltrue([
          for from_item in try(rule.from, []) :
          # Ensure at least one source type (principals, namespaces, ip_blocks, etc.) is provided if 'from' is used
          length(from_item.source_principals) > 0 ||
          length(from_item.request_principals) > 0 ||
          length(from_item.namespaces) > 0 ||
          length(from_item.ip_blocks) > 0 ||
          length(from_item.remote_ip_blocks) > 0 ||
          length(from_item.not_source_principals) > 0 ||
          length(from_item.not_request_principals) > 0 ||
          length(from_item.not_namespaces) > 0 ||
          length(from_item.not_ip_blocks) > 0 ||
          length(from_item.not_remote_ip_blocks) > 0
        ])
      ])
    ])
    error_message = "Each 'from' condition in an AuthorizationPolicy rule must specify at least one source (e.g., source_principals, namespaces, ip_blocks)."
  }

  validation {
    condition = alltrue([
      for ap_item in var.authorization_policies :
      alltrue([
        for rule in try(ap_item.rules, []) :
        alltrue([
          for to_item in try(rule.to, []) :
          # Ensure at least one operation type (hosts, methods, paths, ports) is provided if 'to' is used
          length(to_item.hosts) > 0 || # Updated condition
          length(to_item.methods) > 0 ||
          length(to_item.paths) > 0 ||
          length(to_item.ports) > 0 ||
          length(to_item.not_hosts) > 0 || # Updated condition
          length(to_item.not_methods) > 0 ||
          length(to_item.not_paths) > 0 ||
          length(to_item.not_ports) > 0
        ])
      ])
    ])
    error_message = "Each 'to' condition in an AuthorizationPolicy rule must specify at least one operation (e.g., hosts, methods, paths, ports)."
  }

  # Example usage in a `main.tf` or `terraform.tfvars`:
  # authorization_policies = [
  #   {
  #     name        = "allow-httpbin-get"
  #     namespace   = "default"
  #     selector    = { "app" = "httpbin" } # Applies to pods with label app=httpbin
  #     action      = "ALLOW"
  #     rules = [
  #       {
  #         from = [{
  #           source_principals = ["cluster.local/ns/istio-system/sa/istio-ingressgateway-service-account"]
  #         }]
  #         to = [{
  #           methods = ["GET"]
  #           paths   = ["/status/*"]
  #         }]
  #         when = [{
  #           key = "request.headers[x-user-id]"
  #           values = ["authorized-user"]
  #         }]
  #       },
  #       { # Another rule within the same policy (logical OR)
  #         from = [{
  #           namespaces = ["dev"] # Allow from 'dev' namespace
  #         }]
  #         to = [{
  #           methods = ["POST"]
  #         }]
  #       }
  #     ]
  #   },
  #   {
  #     name        = "deny-admin-paths"
  #     namespace   = "admin-app"
  #     selector    = { "app" = "admin-dashboard" }
  #     action      = "DENY"
  #     rules = [
  #       {
  #         to = [{
  #           paths = ["/admin/*"]
  #           not_methods = ["OPTIONS"] # Deny all methods on /admin/* except OPTIONS
  #         }]
  #         when = [{
  #           key = "request.auth.claims[groups]" # Example for JWT claim
  #           not_values = ["admin", "super-admin"]
  #         }]
  #       }
  #     ]
  #   }
  # ]
}
