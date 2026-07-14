# Gateway Class module for Gateway API

A `GatewayClass` is a cluster-scoped template that ties Gateways to a specific controller implementation (e.g. the GKE L7 load balancer). This module creates one or more `GatewayClass` objects from the `gateway_classes` list via `for_each`. These are Gateway API CRDs rendered through `kubernetes_manifest`, so the Gateway API CRDs must already be installed and a cluster must be reachable at plan time.

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
| <a name="input_gateway_classes"></a> [gateway\_classes](#input\_gateway\_classes) | A list of GatewayClass objects to create. | <pre>list(object({<br/>    name            = string<br/>    labels          = optional(map(string))<br/>    annotations     = optional(map(string))<br/>    controller_name = string<br/>    description     = optional(string)<br/>    parameters_ref = optional(object({<br/>      group     = string<br/>      kind      = string<br/>      name      = string<br/>      namespace = optional(string)<br/>    }))<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_gateway_classes"></a> [gateway\_classes](#output\_gateway\_classes) | Map of created GatewayClasses keyed by name. Reference the name from a Gateway's gateway\_class\_name. |
<!-- END_TF_DOCS -->

## Usage

### with Terraform

```terraform
module "gateway_class" {
  source = "./modules/gateway-api-objects/gatewayclass"

  gateway_classes = [
    {
      name            = "gke-l7-gxlb"
      controller_name = "networking.gke.io/gateway"
      description     = "GKE L7 Gateway Class"
    }
  ]
}

```

### with Terragrunt

```terraform
...

inputs = {
  gateway_classes = [
    {
      name            = "gke-l7-gxlb"
      controller_name = "networking.gke.io/gateway"
      description     = "GKE L7 Gateway Class"
    }
  ]
}
```
