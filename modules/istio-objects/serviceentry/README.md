# Service Entry for Istio/CSM/ASM
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.37.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.37.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_manifest.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_service_entries"></a> [service\_entries](#input\_service\_entries) | A list of Istio ServiceEntry configurations. | <pre>list(object({<br>    name        = string<br>    namespace   = string<br>    labels      = optional(map(string))<br>    annotations = optional(map(string))<br><br>    hosts     = list(string)               # The hosts associated with the ServiceEntry (e.g., "mybank.com", "my-db.internal")<br>    addresses = optional(list(string), []) # IP addresses or CIDR blocks for the service entry (e.g., ["1.1.1.1", "10.0.0.0/24"])<br><br>    ports = list(object({<br>      number      = number           # Port number<br>      name        = string           # Port name (e.g., "http", "https")<br>      protocol    = string           # Protocol (e.g., "HTTP", "HTTPS", "HTTP2", "TCP", "TLS", "GRPC", "MONGO")<br>      target_port = optional(number) # Only for MESH_EXTERNAL locations if target port differs from service port<br>    }))<br><br>    # "MESH_EXTERNAL" (default) or "MESH_INTERNAL"<br>    # MESH_EXTERNAL: services outside the mesh<br>    # MESH_INTERNAL: services inside the mesh but not defined by Kubernetes (e.g., custom service discovery)<br>    location = optional(string, "MESH_EXTERNAL")<br><br>    # "NONE", "STATIC", "DNS", "DNS_ROUND_ROBIN"<br>    # NONE: No endpoint IP resolution (DNS lookup is done by proxy directly)<br>    # STATIC: Endpoints are explicitly specified in 'endpoints' field<br>    # DNS: DNS lookup at proxy, but no round robin among IPs<br>    # DNS_ROUND_ROBIN: DNS lookup at proxy with round robin load balancing<br>    resolution = optional(string, "DNS") # Default to DNS for most external services<br><br>    endpoints = optional(list(object({ # Required if resolution is "STATIC"<br>      address         = string         # IP address or hostname of the endpoint<br>      ports           = map(number)    # Map of port name to port number (e.g., { "http": 80, "https": 443 })<br>      labels          = optional(map(string), {})<br>      network         = optional(string) # Name of the network the endpoint belongs to<br>      locality        = optional(string) # Locality of the endpoint (e.g., "us-west/zone1")<br>      weight          = optional(number) # Weight for load balancing<br>      service_account = optional(string) # Service account associated with the endpoint<br>      tls_mode        = optional(string) # "SIMPLE", "ISTIO_MUTUAL" (for traffic to this endpoint)<br>    })), [])<br><br>    # Defines the namespaces to which this ServiceEntry is exported.<br>    # - ".": Exported to the current namespace only (default if omitted).<br>    # - "*": Exported to all namespaces in the mesh.<br>    # - "~": Not exported to any namespace.<br>    # - ["ns1", "ns2"]: Exported to specific namespaces.<br>    export_to = optional(list(string), ["."])<br>  }))</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with Terragrunt

```terraform
...

inputs = { 
  service_entries = [
    {
      name        = "external-api"
      namespace   = "default"
      hosts       = ["api.example.com"]
      addresses   = ["192.168.1.1/32"] # Optional IP or CIDR for DNS resolution
      ports = [
        { number = 443, name = "https", protocol = "HTTPS" }
      ]
      location    = "MESH_EXTERNAL"
      resolution  = "DNS" # Proxy will resolve api.example.com via DNS
      export_to   = ["."] # Export only to the current namespace (default if omitted)
    },
    {
      name        = "static-db-entry"
      namespace   = "default"
      hosts       = ["mydb.internal"]
      ports = [
        { number = 5432, name = "tcp-db", protocol = "TCP" }
      ]
      location    = "MESH_EXTERNAL"
      resolution  = "STATIC" # Endpoints are explicitly listed
      endpoints = [
        {
          address = "10.0.0.100"
          ports   = { "tcp-db" = 5432 }
          labels  = { "region" = "us-east-1" }
          weight  = 100
        },
        {
          address = "10.0.0.101"
          ports   = { "tcp-db" = 5432 }
          labels  = { "region" = "us-east-1" }
          weight  = 100
        }
      ]
      export_to = ["*"] # Export to all namespaces in the mesh
    },
    {
      name        = "internal-mesh-svc"
      namespace   = "internal-services"
      hosts       = ["custom-svc.internal"]
      ports = [
        { number = 80, name = "http-svc", protocol = "HTTP" }
      ]
      location    = "MESH_INTERNAL" # Useful for custom service discovery
      resolution  = "DNS"
      export_to   = ["prod-ns", "staging-ns"] # Export to specific namespaces
    },
    {
      name        = "private-local-svc"
      namespace   = "dev-tools"
      hosts       = ["my-dev-tool.local"]
      ports = [
        { number = 8080, name = "http-dev", protocol = "HTTP" }
      ]
      resolution  = "STATIC"
      endpoints   = [{ address = "127.0.0.1", ports = { "http-dev" = 8080 } }]
      export_to   = ["~"] # Not exported to any namespace
    }
  ]
}
```
