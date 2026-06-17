# TLSRoute module for Gateway API

Manages Gateway API **TLSRoute** objects (`gateway.networking.k8s.io/v1alpha2`, experimental channel) that route TLS traffic by SNI to backend Services. The module renders one TLSRoute per entry in its `list(object)` input via `for_each`. These are CRDs applied through `kubernetes_manifest`, so the experimental-channel Gateway API CRDs must already be installed and the cluster must be reachable at plan time.

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
| <a name="input_tls_routes"></a> [tls\_routes](#input\_tls\_routes) | A list of TLSRoute objects to create. | <pre>list(object({<br/>    name        = string<br/>    namespace   = string<br/>    labels      = optional(map(string))<br/>    annotations = optional(map(string))<br/>    parent_refs = list(object({<br/>      group        = optional(string)<br/>      kind         = optional(string)<br/>      name         = string<br/>      namespace    = optional(string)<br/>      section_name = optional(string)<br/>      port         = optional(number)<br/>    }))<br/>    hostnames = optional(list(string))<br/>    rules = list(object({<br/>      name = optional(string)<br/>      backend_refs = optional(list(object({<br/>        group     = optional(string)<br/>        kind      = optional(string)<br/>        name      = string<br/>        namespace = optional(string)<br/>        port      = number<br/>        weight    = optional(number, 1)<br/>      })), [])<br/>    }))<br/>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with Terraform

```terraform
module "tlsroute" {
  source = "./modules/gateway-api-objects/tlsroute"

  tls_routes = [
    {
      name      = "passthrough"
      namespace = "default"
      parent_refs = [
        {
          name = "tls-gateway"
        }
      ]
      hostnames = ["secure.example.com"]
      rules = [
        {
          backend_refs = [
            {
              name = "secure-backend"
              port = 8443
            }
          ]
        }
      ]
    }
  ]
}
```
