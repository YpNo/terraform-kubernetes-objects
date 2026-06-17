# GCPGatewayPolicy module
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
| <a name="input_gcp_gateway_policies"></a> [gcp\_gateway\_policies](#input\_gcp\_gateway\_policies) | A list of GCPGatewayPolicy configurations. | <pre>list(object({<br/>    name        = string<br/>    namespace   = optional(string, "istio-system")<br/>    labels      = optional(map(string))<br/>    annotations = optional(map(string))<br/>    # spec.default - the LoadBalancer policy configuration applied to the Gateway.<br/>    allow_global_access = optional(bool)<br/>    ssl_policy          = optional(string) # name of the SSL policy<br/>    region              = optional(string) # load balancer region for Multi-cluster Gateway<br/>    # spec.targetRef - the Gateway the policy attaches to.<br/>    target_ref = object({<br/>      group     = optional(string, "gateway.networking.k8s.io")<br/>      kind      = optional(string, "Gateway")<br/>      name      = string<br/>      namespace = optional(string)<br/>    })<br/>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with Terragrunt

```terraform
...

inputs = {
  gcp_gateway_policies = [
    {
      name                = "external-gateway-policy"
      namespace           = "istio-system"
      allow_global_access = true
      ssl_policy          = "my-ssl-policy"
      target_ref = {
        group = "gateway.networking.k8s.io"
        kind  = "Gateway"
        name  = "external-http"
      }
    }
  ]
}
```
