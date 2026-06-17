# EnvoyFilter module

Istio `EnvoyFilter` applies low-level, custom patches directly to the Envoy proxy configuration that Istio generates, for cases not covered by higher-level APIs. This module creates one or more filters from a `list(object)` input via `for_each`. Because these are Istio CRDs rendered through `kubernetes_manifest`, the Istio CRDs must already be installed and a cluster must be reachable at plan time.

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
| <a name="input_envoy_filters"></a> [envoy\_filters](#input\_envoy\_filters) | A list of Istio EnvoyFilter configurations. | <pre>list(object({<br/>    name        = string<br/>    namespace   = string<br/>    labels      = optional(map(string), {})<br/>    annotations = optional(map(string), {})<br/><br/>    # Criteria to select the specific set of pods/VMs on which this EnvoyFilter applies.<br/>    # If omitted, the EnvoyFilter applies to all workloads in the namespace.<br/>    workload_selector = optional(object({<br/>      labels = map(string)<br/>    }))<br/><br/>    # One or more patches to apply to the generated Envoy configuration.<br/>    config_patches = optional(list(object({<br/>      # Where in the Envoy configuration the patch applies, e.g.,<br/>      # "LISTENER", "FILTER_CHAIN", "NETWORK_FILTER", "HTTP_FILTER", "ROUTE_CONFIGURATION",<br/>      # "VIRTUAL_HOST", "HTTP_ROUTE", "CLUSTER", "EXTENSION_CONFIG", "BOOTSTRAP", "LISTENER_FILTER".<br/>      apply_to = string<br/><br/>      # Match conditions selecting the object to patch. The nested listener,<br/>      # routeConfiguration and cluster blocks are free-form maps mirroring the<br/>      # Envoy match semantics.<br/>      match = optional(object({<br/>        context             = optional(string) # "ANY", "SIDECAR_INBOUND", "SIDECAR_OUTBOUND", "GATEWAY"<br/>        listener            = optional(any)<br/>        route_configuration = optional(any)<br/>        cluster             = optional(any)<br/>      }))<br/><br/>      # The patch to apply along with the operation.<br/>      patch = object({<br/>        # "MERGE", "ADD", "REMOVE", "INSERT_BEFORE", "INSERT_AFTER", "INSERT_FIRST", "REPLACE"<br/>        operation = string<br/>        # Free-form structure merged into / used to build the target object.<br/>        value = optional(any)<br/>      })<br/>    })), [])<br/>  }))</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with Terragrunt

```terraform
...

inputs = {
  envoy_filters = [
    {
      name      = "set-server-header"
      namespace = "istio-system"
      workload_selector = {
        labels = { istio = "ingressgateway" }
      }
      config_patches = [
        {
          apply_to = "NETWORK_FILTER"
          match = {
            context = "GATEWAY"
            listener = {
              filterChain = {
                filter = {
                  name = "envoy.filters.network.http_connection_manager"
                }
              }
            }
          }
          patch = {
            operation = "MERGE"
            value = {
              typed_config = {
                "@type"            = "type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager"
                server_name        = "my-gateway"
                server_header_transformation = "OVERWRITE"
              }
            }
          }
        }
      ]
    }
  ]
}
```

