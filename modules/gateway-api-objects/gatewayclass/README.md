# Gateway Class module for Gateway API
<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_manifest.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_gateway_classes"></a> [gateway\_classes](#input\_gateway\_classes) | A list of GatewayClass objects to create. | <pre>list(object({<br>    name            = string<br>    labels          = optional(map(string))<br>    annotations     = optional(map(string))<br>    controller_name = string<br>    description     = optional(string)<br>    parameters_ref = optional(object({<br>      group     = string<br>      kind      = string<br>      name      = string<br>      namespace = optional(string)<br>    }))<br>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
# with Terraform

```terraform
...

module "gateway_class" {
  source = "./modules/gke-gateway-class"

  gateway_classes = [
    {
      name            = "gke-l7-gxlb"
      controller_name = "networking.gke.io/gateway"
      description     = "GKE L7 Gateway Class"
    }
  ]
}

```
