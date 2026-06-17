# Gateway module for Istio/CSM/ASM

Istio `Gateway` configures a load balancer at the edge of the mesh, declaring the ports, protocols, hosts, and TLS settings for inbound (or outbound) traffic; it is typically paired with a `VirtualService` for routing. This module creates one or more gateways from a `list(object)` input via `for_each`. Because these are Istio CRDs rendered through `kubernetes_manifest`, the Istio CRDs must already be installed and a cluster must be reachable at plan time.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.37.1 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.37.1 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [kubernetes_manifest.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_gateways"></a> [gateways](#input\_gateways) | A list of Istio Gateway configurations. | <pre>list(object({<br/>    name        = string<br/>    namespace   = string<br/>    labels      = optional(map(string), null)<br/>    annotations = optional(map(string), null)<br/>    selector    = map(string) # Labels of the Istio proxy workload (e.g., { "istio": "ingressgateway" })<br/><br/>    servers = list(object({<br/>      port = object({<br/>        number   = number<br/>        name     = string<br/>        protocol = string # e.g., "HTTP", "HTTPS", "TCP", "TLS", "GRPC", "HTTP/2"<br/>      })<br/>      hosts = list(string) # e.g., ["*.example.com", "my-app.my-namespace.svc.cluster.local"]<br/><br/>      tls = optional(object({<br/>        mode                 = string                     # "SIMPLE", "MUTUAL", "PASSTHROUGH", "AUTO_PASSTHROUGH", "ISTIO_MUTUAL"<br/>        credential_name      = optional(string)           # Name of the Kubernetes Secret (for SIMPLE mode)<br/>        private_key          = optional(string)           # Path to key file (if not using credentialName)<br/>        server_certificate   = optional(string)           # Path to cert file (if not using credentialName)<br/>        ca_certificates      = optional(string)           # Path to CA certs file (for MUTUAL mode)<br/>        subject_alt_names    = optional(list(string), []) # List of SANs<br/>        min_protocol_version = optional(string)           # e.g., "TLSV1_2", "TLSV1_3"<br/>        max_protocol_version = optional(string)           # e.g., "TLSV1_2", "TLSV1_3"<br/>        cipher_suites        = optional(list(string), []) # Specific cipher suites<br/>        credential_source    = optional(string)           # e.g., "SECRET_STORE"<br/>      }))<br/>    }))<br/>  }))</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with Terragrunt

```terraform
...

inputs = { 
  gateways = [
    {
      name        = "http-gateway"
      namespace   = "istio-system"
      selector    = { "istio" = "ingressgateway" } # Targets the default Istio ingress gateway
      servers = [
        {
          port = {
            number   = 80
            name     = "http"
            protocol = "HTTP"
          }
          hosts = ["*.example.com"]
        }
      ]
    },
    {
      name        = "https-gateway"
      namespace   = "istio-system"
      selector    = { "istio" = "ingressgateway" }
      servers = [
        {
          port = {
            number   = 443
            name     = "https"
            protocol = "HTTPS"
          }
          hosts = ["secure.example.com"]
          tls = {
            mode            = "SIMPLE"
            credential_name = "example-com-cert" # Kubernetes Secret name for TLS certs
          }
        },
        {
          port = {
            number = 15443 # Default Istio TLS port for custom gateways
            name = "istio-mutual-tls"
            protocol = "TLS"
          }
          hosts = ["*.internal.svc.cluster.local"]
          tls = {
            mode = "ISTIO_MUTUAL"
          }
        }
      ]
    }
  ]
}
```
