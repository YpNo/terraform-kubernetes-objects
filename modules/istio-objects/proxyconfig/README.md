# ProxyConfig module

Istio `ProxyConfig` tunes the Envoy sidecar proxy for selected workloads, setting worker concurrency, extra environment variables, and the proxy image variant. This module creates one or more configs from a `list(object)` input via `for_each`. Because these are Istio CRDs rendered through `kubernetes_manifest`, the Istio CRDs must already be installed and a cluster must be reachable at plan time.

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
| <a name="input_proxy_configs"></a> [proxy\_configs](#input\_proxy\_configs) | A list of Istio ProxyConfig configurations. | <pre>list(object({<br/>    name        = string<br/>    namespace   = string<br/>    labels      = optional(map(string))<br/>    annotations = optional(map(string))<br/><br/>    # Selects the set of pods/VMs on which this ProxyConfig is applied.<br/>    # If omitted, the ProxyConfig applies to all workloads in the namespace.<br/>    selector = optional(object({<br/>      match_labels = map(string)<br/>    }))<br/><br/>    # Number of worker threads to run. If unset, determined from CPU limits.<br/>    concurrency = optional(number)<br/><br/>    # Additional environment variables for the proxy. Names starting with<br/>    # "ISTIO_META_" are also included in the bootstrap configuration.<br/>    environment_variables = optional(map(string), {})<br/><br/>    # Proxy image details.<br/>    image = optional(object({<br/>      # "default", "debug", or "distroless".<br/>      image_type = string<br/>    }))<br/>  }))</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with Terragrunt

```terraform
...

inputs = {
  proxy_configs = [
    {
      name      = "high-concurrency"
      namespace = "bookinfo"
      selector  = { match_labels = { app = "ratings" } }
      concurrency = 4
      environment_variables = {
        ISTIO_META_DNS_CAPTURE = "true"
      }
      image = { image_type = "distroless" }
    }
  ]
}
```
