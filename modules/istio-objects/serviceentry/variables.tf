variable "service_entries" {
  description = "A list of Istio ServiceEntry configurations."
  type = list(object({
    name        = string
    namespace   = string
    labels      = optional(map(string))
    annotations = optional(map(string))

    hosts     = list(string)               # The hosts associated with the ServiceEntry (e.g., "mybank.com", "my-db.internal")
    addresses = optional(list(string), []) # IP addresses or CIDR blocks for the service entry (e.g., ["1.1.1.1", "10.0.0.0/24"])

    ports = list(object({
      number      = number           # Port number
      name        = string           # Port name (e.g., "http", "https")
      protocol    = string           # Protocol (e.g., "HTTP", "HTTPS", "HTTP2", "TCP", "TLS", "GRPC", "MONGO")
      target_port = optional(number) # Only for MESH_EXTERNAL locations if target port differs from service port
    }))

    # "MESH_EXTERNAL" (default) or "MESH_INTERNAL"
    # MESH_EXTERNAL: services outside the mesh
    # MESH_INTERNAL: services inside the mesh but not defined by Kubernetes (e.g., custom service discovery)
    location = optional(string, "MESH_EXTERNAL")

    # "NONE", "STATIC", "DNS", "DNS_ROUND_ROBIN"
    # NONE: No endpoint IP resolution (DNS lookup is done by proxy directly)
    # STATIC: Endpoints are explicitly specified in 'endpoints' field
    # DNS: DNS lookup at proxy, but no round robin among IPs
    # DNS_ROUND_ROBIN: DNS lookup at proxy with round robin load balancing
    resolution = optional(string, "DNS") # Default to DNS for most external services

    endpoints = optional(list(object({ # Required if resolution is "STATIC"
      address         = string         # IP address or hostname of the endpoint
      ports           = map(number)    # Map of port name to port number (e.g., { "http": 80, "https": 443 })
      labels          = optional(map(string), {})
      network         = optional(string) # Name of the network the endpoint belongs to
      locality        = optional(string) # Locality of the endpoint (e.g., "us-west/zone1")
      weight          = optional(number) # Weight for load balancing
      service_account = optional(string) # Service account associated with the endpoint
      tls_mode        = optional(string) # "SIMPLE", "ISTIO_MUTUAL" (for traffic to this endpoint)
    })), [])

    # Defines the namespaces to which this ServiceEntry is exported.
    # - ".": Exported to the current namespace only (default if omitted).
    # - "*": Exported to all namespaces in the mesh.
    # - "~": Not exported to any namespace.
    # - ["ns1", "ns2"]: Exported to specific namespaces.
    export_to = optional(list(string), ["."])
  }))

  validation {
    condition = alltrue([
      for se_item in var.service_entries :
      contains(["MESH_EXTERNAL", "MESH_INTERNAL"], se_item.location)
    ])
    error_message = "Invalid 'location' for ServiceEntry. Must be one of: 'MESH_EXTERNAL', 'MESH_INTERNAL'."
  }

  validation {
    condition = alltrue([
      for se_item in var.service_entries :
      contains(["NONE", "STATIC", "DNS", "DNS_ROUND_ROBIN"], se_item.resolution)
    ])
    error_message = "Invalid 'resolution' for ServiceEntry. Must be one of: 'NONE', 'STATIC', 'DNS', 'DNS_ROUND_ROBIN'."
  }

  validation {
    condition = alltrue([
      for se_item in var.service_entries :
      se_item.resolution != "STATIC" || length(se_item.endpoints) > 0
    ])
    error_message = "If 'resolution' is 'STATIC', the 'endpoints' list must not be empty."
  }

  validation {
    condition = alltrue([
      for se_item in var.service_entries :
      alltrue([
        for port in se_item.ports :
        contains(["HTTP", "HTTPS", "HTTP2", "TCP", "TLS", "GRPC", "MONGO"], port.protocol)
      ])
    ])
    error_message = "Invalid 'protocol' for ServiceEntry port. Must be one of: 'HTTP', 'HTTPS', 'HTTP2', 'TCP', 'TLS', 'GRPC', 'MONGO'."
  }

  validation {
    condition = alltrue([
      for se_item in var.service_entries :
      alltrue([
        for ep in try(se_item.endpoints, []) :
        ep.tls_mode == null || contains(["SIMPLE", "ISTIO_MUTUAL"], ep.tls_mode)
      ])
    ])
    error_message = "Invalid 'tls_mode' for ServiceEntry endpoint. Must be one of: 'SIMPLE', 'ISTIO_MUTUAL'."
  }

  validation {
    condition = alltrue([
      for se_item in var.service_entries :
      # Validate export_to contents: only '.', '*', '~', or valid namespace names
      alltrue([
        for export_target in se_item.export_to :
        # If it's a specific namespace name, it should not be '.' or '*' or '~'
        (export_target == "." || export_target == "*" || export_target == "~") || (!contains([".", "*", "~"], export_target))
      ]) &&
      # If '.' or '*' or '~' is used, it should be the only element
      (length(se_item.export_to) <= 1 || (!contains(se_item.export_to, ".") && !contains(se_item.export_to, "*") && !contains(se_item.export_to, "~")))
    ])
    error_message = "Invalid 'export_to' values. If '.' (current namespace), '*' (all namespaces), or '~' (no export) is used, it must be the only element in the list. Otherwise, provide valid namespace names."
  }

  # Example usage in a `main.tf` or `terraform.tfvars`:
  # service_entries = [
  #   {
  #     name        = "external-api"
  #     namespace   = "default"
  #     hosts       = ["api.example.com"]
  #     addresses   = ["192.168.1.1/32"] # Optional IP or CIDR for DNS resolution
  #     ports = [
  #       { number = 443, name = "https", protocol = "HTTPS" }
  #     ]
  #     location    = "MESH_EXTERNAL"
  #     resolution  = "DNS" # Proxy will resolve api.example.com via DNS
  #     export_to   = ["."] # Export only to the current namespace (default if omitted)
  #   },
  #   {
  #     name        = "static-db-entry"
  #     namespace   = "default"
  #     hosts       = ["mydb.internal"]
  #     ports = [
  #       { number = 5432, name = "tcp-db", protocol = "TCP" }
  #     ]
  #     location    = "MESH_EXTERNAL"
  #     resolution  = "STATIC" # Endpoints are explicitly listed
  #     endpoints = [
  #       {
  #         address = "10.0.0.100"
  #         ports   = { "tcp-db" = 5432 }
  #         labels  = { "region" = "us-east-1" }
  #         weight  = 100
  #       },
  #       {
  #         address = "10.0.0.101"
  #         ports   = { "tcp-db" = 5432 }
  #         labels  = { "region" = "us-east-1" }
  #         weight  = 100
  #       }
  #     ]
  #     export_to = ["*"] # Export to all namespaces in the mesh
  #   },
  #   {
  #     name        = "internal-mesh-svc"
  #     namespace   = "internal-services"
  #     hosts       = ["custom-svc.internal"]
  #     ports = [
  #       { number = 80, name = "http-svc", protocol = "HTTP" }
  #     ]
  #     location    = "MESH_INTERNAL" # Useful for custom service discovery
  #     resolution  = "DNS"
  #     export_to   = ["prod-ns", "staging-ns"] # Export to specific namespaces
  #   }
  #   {
  #     name        = "private-local-svc"
  #     namespace   = "dev-tools"
  #     hosts       = ["my-dev-tool.local"]
  #     ports = [
  #       { number = 8080, name = "http-dev", protocol = "HTTP" }
  #     ]
  #     resolution  = "STATIC"
  #     endpoints   = [{ address = "127.0.0.1", ports = { "http-dev" = 8080 } }]
  #     export_to   = ["~"] # Not exported to any namespace
  #   }
  # ]
}
