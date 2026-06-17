# TCPRoute module for Gateway API

A `TCPRoute` forwards raw TCP traffic from a Gateway listener to one or more backend Services. This module creates one or more `TCPRoute` objects from the `tcp_routes` list via `for_each`. These are Gateway API CRDs rendered through `kubernetes_manifest`, so the Gateway API CRDs must already be installed and a cluster must be reachable at plan time.

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
| <a name="input_tcp_routes"></a> [tcp\_routes](#input\_tcp\_routes) | A list of TCPRoute objects to create. | <pre>list(object({<br/>    name        = string<br/>    namespace   = string<br/>    labels      = optional(map(string))<br/>    annotations = optional(map(string))<br/>    parent_refs = list(object({<br/>      group        = optional(string)<br/>      kind         = optional(string)<br/>      name         = string<br/>      namespace    = optional(string)<br/>      section_name = optional(string)<br/>      port         = optional(number)<br/>    }))<br/>    rules = list(object({<br/>      name = optional(string)<br/>      backend_refs = optional(list(object({<br/>        group     = optional(string)<br/>        kind      = optional(string)<br/>        name      = string<br/>        namespace = optional(string)<br/>        port      = number<br/>        weight    = optional(number, 1)<br/>      })), [])<br/>    }))<br/>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with Terraform

```terraform
module "tcproute" {
  source = "./modules/gateway-api-objects/tcproute"

  tcp_routes = [
    {
      name      = "redis"
      namespace = "default"
      parent_refs = [
        {
          name        = "tcp-gateway"
          section_name = "redis"
        }
      ]
      rules = [
        {
          backend_refs = [
            {
              name = "redis-server"
              port = 6379
            }
          ]
        }
      ]
    }
  ]
}
```
