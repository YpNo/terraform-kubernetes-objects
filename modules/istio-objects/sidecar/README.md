# Sidecar module

Istio `Sidecar` scopes a workload's proxy configuration, limiting which inbound ports it accepts and which outbound hosts it can reach, which reduces proxy memory and configuration footprint. This module creates one or more sidecar configs from a `list(object)` input via `for_each`. Because these are Istio CRDs rendered through `kubernetes_manifest`, the Istio CRDs must already be installed and a cluster must be reachable at plan time.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.37.1 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 3.2.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [kubernetes_manifest.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_sidecars"></a> [sidecars](#input\_sidecars) | A list of Istio Sidecar configurations. | <pre>list(object({<br/>    name        = string<br/>    namespace   = string<br/>    labels      = optional(map(string), {})<br/>    annotations = optional(map(string), {})<br/><br/>    # Criteria to select the specific set of pods/VMs on which this Sidecar applies.<br/>    # If omitted, the Sidecar applies to all workloads in the namespace.<br/>    workload_selector = optional(object({<br/>      labels = map(string)<br/>    }))<br/><br/>    # Inbound listeners for traffic to the attached workload(s).<br/>    ingress = optional(list(object({<br/>      port = object({<br/>        number   = number<br/>        protocol = string # "HTTP", "HTTPS", "GRPC", "HTTP2", "MONGO", "TCP", "TLS"<br/>        name     = string<br/>      })<br/>      bind             = optional(string) # IP/Unix domain socket the listener binds to<br/>      capture_mode     = optional(string) # "DEFAULT", "IPTABLES", "NONE"<br/>      default_endpoint = optional(string) # e.g., "127.0.0.1:8080" or "unix:///path/to/socket"<br/>    })), [])<br/><br/>    # Outbound listeners describing the egress traffic from the attached workload(s).<br/>    egress = optional(list(object({<br/>      port = optional(object({<br/>        number   = number<br/>        protocol = string<br/>        name     = string<br/>      }))<br/>      bind         = optional(string)<br/>      capture_mode = optional(string) # "DEFAULT", "IPTABLES", "NONE"<br/>      hosts        = list(string)     # e.g., ["./*", "istio-system/*"]<br/>    })), [])<br/><br/>    # Configuration for the outbound traffic policy.<br/>    outbound_traffic_policy = optional(object({<br/>      mode = string # "REGISTRY_ONLY" or "ALLOW_ANY"<br/>    }))<br/>  }))</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with Terragrunt

```terraform
...

inputs = {
  sidecars = [
    {
      name      = "default-egress"
      namespace = "default"
      # Restrict egress to same namespace and istio-system only.
      egress = [
        {
          hosts = ["./*", "istio-system/*"]
        }
      ]
      outbound_traffic_policy = {
        mode = "REGISTRY_ONLY"
      }
    },
    {
      name      = "ratings-sidecar"
      namespace = "bookinfo"
      workload_selector = {
        labels = { app = "ratings" }
      }
      ingress = [
        {
          port             = { number = 9080, protocol = "HTTP", name = "http" }
          default_endpoint = "127.0.0.1:8080"
          capture_mode     = "DEFAULT"
        }
      ]
      egress = [
        {
          port         = { number = 9080, protocol = "HTTP", name = "http" }
          hosts        = ["./*"]
          capture_mode = "IPTABLES"
        }
      ]
    }
  ]
}
```

