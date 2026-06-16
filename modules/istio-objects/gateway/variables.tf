variable "gateways" {
  description = "A list of Istio Gateway configurations."
  type = list(object({
    name        = string
    namespace   = string
    labels      = optional(map(string), null)
    annotations = optional(map(string), null)
    selector    = map(string) # Labels of the Istio proxy workload (e.g., { "istio": "ingressgateway" })

    servers = list(object({
      port = object({
        number   = number
        name     = string
        protocol = string # e.g., "HTTP", "HTTPS", "TCP", "TLS", "GRPC", "HTTP/2"
      })
      hosts = list(string) # e.g., ["*.example.com", "my-app.my-namespace.svc.cluster.local"]

      tls = optional(object({
        mode                 = string                     # "SIMPLE", "MUTUAL", "PASSTHROUGH", "AUTO_PASSTHROUGH", "ISTIO_MUTUAL"
        credential_name      = optional(string)           # Name of the Kubernetes Secret (for SIMPLE mode)
        private_key          = optional(string)           # Path to key file (if not using credentialName)
        server_certificate   = optional(string)           # Path to cert file (if not using credentialName)
        ca_certificates      = optional(string)           # Path to CA certs file (for MUTUAL mode)
        subject_alt_names    = optional(list(string), []) # List of SANs
        min_protocol_version = optional(string)           # e.g., "TLSV1_2", "TLSV1_3"
        max_protocol_version = optional(string)           # e.g., "TLSV1_2", "TLSV1_3"
        cipher_suites        = optional(list(string), []) # Specific cipher suites
        credential_source    = optional(string)           # e.g., "SECRET_STORE"
      }))
    }))
  }))

  validation {
    condition = alltrue([
      for gw_item in var.gateways :
      alltrue([
        for server in gw_item.servers :
        contains(["HTTP", "HTTPS", "TCP", "TLS", "GRPC", "HTTP/2"], server.port.protocol)
      ])
    ])
    error_message = "Invalid 'protocol' for Gateway port. Must be one of: 'HTTP', 'HTTPS', 'TCP', 'TLS', 'GRPC', 'HTTP/2'."
  }

  validation {
    condition = alltrue([
      for gateway in var.gateways :
      alltrue([
        for server in gateway.servers :
        # Combined validation logic for all server-level checks
        (
          # Check 1: TLS mode validity (only if TLS is present)
          server.tls == null ? true : contains(["SIMPLE", "MUTUAL", "PASSTHROUGH", "AUTO_PASSTHROUGH", "ISTIO_MUTUAL"], server.tls.mode)
        ) &&
        (
          # Check 2: Credential requirements for SIMPLE mode (only if TLS is present)
          server.tls == null ? true :
          (server.tls.mode == "SIMPLE" && server.tls.credential_name == null ?
            (server.tls.private_key != null && server.tls.server_certificate != null) : true
          )
        ) &&
        (
          # Check 3: Ports - protocol match (as an example, if you had this)
          # server.port.protocol == "HTTPS" ? server.tls != null : true
          true # Placeholder if you don't have other protocol-specific checks
        )
      ])
    ])
    error_message = "Invalid Gateway configuration: \n" # Customize this for better feedback

    # You might want to break down error messages for better specificity if there are many conditions.
    # For instance, a separate validation block for each major condition if it provides clearer errors.
    # However, combining with `&&` and a generic message is also common.
  }

  validation {
    condition = alltrue([
      for gateway in var.gateways :
      alltrue([
        for server in gateway.servers :
        # Check if server.tls is null FIRST.
        # If server.tls is null (no TLS config), the condition is true.
        # If server.tls is not null, then proceed with the existing TLS validation.
        (server.tls == null ? true :
          (server.tls.mode == "SIMPLE" && server.tls.credential_name == null ?
            (server.tls.private_key != null && server.tls.server_certificate != null) : true
          )
        )
      ])
    ])
    error_message = "For servers with TLS mode 'SIMPLE' and no 'credential_name', 'private_key' and 'server_certificate' must both be provided."
  }

  # Example usage in a `main.tf` or `terraform.tfvars`:
  # gateways = [
  #   {
  #     name        = "http-gateway"
  #     namespace   = "istio-system"
  #     selector    = { "istio" = "ingressgateway" } # Targets the default Istio ingress gateway
  #     servers = [
  #       {
  #         port = {
  #           number   = 80
  #           name     = "http"
  #           protocol = "HTTP"
  #         }
  #         hosts = ["*.example.com"]
  #       }
  #     ]
  #   },
  #   {
  #     name        = "https-gateway"
  #     namespace   = "istio-system"
  #     selector    = { "istio" = "ingressgateway" }
  #     servers = [
  #       {
  #         port = {
  #           number   = 443
  #           name     = "https"
  #           protocol = "HTTPS"
  #         }
  #         hosts = ["secure.example.com"]
  #         tls = {
  #           mode            = "SIMPLE"
  #           credential_name = "example-com-cert" # Kubernetes Secret name for TLS certs
  #         }
  #       },
  #       {
  #         port = {
  #           number = 15443 # Default Istio TLS port for custom gateways
  #           name = "istio-mutual-tls"
  #           protocol = "TLS"
  #         }
  #         hosts = ["*.internal.svc.cluster.local"]
  #         tls = {
  #           mode = "ISTIO_MUTUAL"
  #         }
  #       }
  #     ]
  #   }
  # ]
}