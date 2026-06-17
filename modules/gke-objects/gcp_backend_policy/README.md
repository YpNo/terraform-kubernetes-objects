# GCPBackendPolicy module

A GCPBackendPolicy is a GKE Gateway API CRD that applies Google Cloud load balancer backend settings (Cloud Armor, IAP, timeouts, session affinity, logging, connection draining) to a Service via a `targetRef`. This module creates one GCPBackendPolicy per entry in the `gcp_backend_policies` list via `for_each`. Because these are rendered with `kubernetes_manifest`, the GKE GCPBackendPolicy CRD must already be installed and the cluster reachable at plan time.

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
| <a name="input_gcp_backend_policies"></a> [gcp\_backend\_policies](#input\_gcp\_backend\_policies) | A list of GCPBackendPolicy configurations. | <pre>list(object({<br/>    name        = string<br/>    namespace   = optional(string, "istio-system")<br/>    labels      = optional(map(string))<br/>    annotations = optional(map(string))<br/>    # spec.default - the LoadBalancer policy configuration applied to the backend.<br/>    backend_preference    = optional(string) # DEFAULT | PREFERRED<br/>    security_policy       = optional(string) # Cloud Armor security policy name<br/>    timeout_sec           = optional(number) # Backend service timeout, 1-2147483647<br/>    max_rate_per_endpoint = optional(number) # 1-1000000000<br/>    logging = optional(object({<br/>      enabled     = bool<br/>      sample_rate = optional(number) # 0-1000000<br/>    }))<br/>    session_affinity = optional(object({<br/>      type           = string           # CLIENT_IP, CLIENT_IP_PORT_PROTO, CLIENT_IP_PROTO, GENERATED_COOKIE, HEADER_FIELD, HTTP_COOKIE, NONE<br/>      cookie_ttl_sec = optional(number) # 0-1209600<br/>    }))<br/>    connection_draining = optional(object({<br/>      draining_timeout_sec = number # 0-3600<br/>    }))<br/>    iap = optional(object({<br/>      enabled                   = bool<br/>      client_id                 = optional(string)<br/>      oauth2_client_secret_name = optional(string) # name of the Kubernetes Secret holding the OAuth2 client secret<br/>    }))<br/>    # spec.targetRef - the resource the policy attaches to.<br/>    target_ref = object({<br/>      group     = optional(string, "")<br/>      kind      = optional(string, "Service")<br/>      name      = string<br/>      namespace = optional(string)<br/>    })<br/>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with Terragrunt

```terraform
...

inputs = {
  gcp_backend_policies = [
    {
      name            = "store-backend"
      namespace       = "default"
      security_policy = "my-cloud-armor-policy"
      timeout_sec     = 30
      logging = {
        enabled     = true
        sample_rate = 1000000
      }
      session_affinity = {
        type           = "GENERATED_COOKIE"
        cookie_ttl_sec = 3600
      }
      connection_draining = {
        draining_timeout_sec = 60
      }
      iap = {
        enabled                   = true
        oauth2_client_secret_name = "iap-oauth-secret"
      }
      target_ref = {
        kind = "Service"
        name = "store"
      }
    }
  ]
}
```
