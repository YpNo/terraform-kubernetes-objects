# UDPRoute module for Gateway API

Manages Gateway API **UDPRoute** objects (`gateway.networking.k8s.io/v1alpha2`, experimental channel) that route UDP traffic to backend Services. The module renders one UDPRoute per entry in its `list(object)` input via `for_each`. These are CRDs applied through `kubernetes_manifest`, so the experimental-channel Gateway API CRDs must already be installed and the cluster must be reachable at plan time.

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
| <a name="input_udp_routes"></a> [udp\_routes](#input\_udp\_routes) | A list of UDPRoute objects to create. | <pre>list(object({<br/>    name        = string<br/>    namespace   = string<br/>    labels      = optional(map(string))<br/>    annotations = optional(map(string))<br/>    parent_refs = list(object({<br/>      group        = optional(string)<br/>      kind         = optional(string)<br/>      name         = string<br/>      namespace    = optional(string)<br/>      section_name = optional(string)<br/>      port         = optional(number)<br/>    }))<br/>    rules = list(object({<br/>      name = optional(string)<br/>      backend_refs = optional(list(object({<br/>        group     = optional(string)<br/>        kind      = optional(string)<br/>        name      = string<br/>        namespace = optional(string)<br/>        port      = number<br/>        weight    = optional(number, 1)<br/>      })), [])<br/>    }))<br/>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with Terraform

```terraform
module "udproute" {
  source = "./modules/gateway-api-objects/udproute"

  udp_routes = [
    {
      name      = "dns"
      namespace = "default"
      parent_refs = [
        {
          name        = "udp-gateway"
          section_name = "dns"
        }
      ]
      rules = [
        {
          backend_refs = [
            {
              name = "coredns"
              port = 53
            }
          ]
        }
      ]
    }
  ]
}
```
