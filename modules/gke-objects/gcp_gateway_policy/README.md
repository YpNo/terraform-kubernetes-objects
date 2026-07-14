# GCPGatewayPolicy module

A GCPGatewayPolicy is a GKE Gateway API CRD that applies Google Cloud load balancer front-end settings (global access, SSL policy, region) to a Gateway via a `targetRef`. This module creates one GCPGatewayPolicy per entry in the `gcp_gateway_policies` list via `for_each`. Because these are rendered with `kubernetes_manifest`, the GKE GCPGatewayPolicy CRD must already be installed and the cluster reachable at plan time.

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
| <a name="input_gcp_gateway_policies"></a> [gcp\_gateway\_policies](#input\_gcp\_gateway\_policies) | A list of GCPGatewayPolicy configurations. | <pre>list(object({<br/>    name        = string<br/>    namespace   = optional(string, "istio-system")<br/>    labels      = optional(map(string))<br/>    annotations = optional(map(string))<br/>    # spec.default - the LoadBalancer policy configuration applied to the Gateway.<br/>    allow_global_access = optional(bool)<br/>    ssl_policy          = optional(string) # name of the SSL policy<br/>    region              = optional(string) # load balancer region for Multi-cluster Gateway<br/>    # spec.targetRef - the Gateway the policy attaches to.<br/>    target_ref = object({<br/>      group     = optional(string, "gateway.networking.k8s.io")<br/>      kind      = optional(string, "Gateway")<br/>      name      = string<br/>      namespace = optional(string)<br/>    })<br/>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage

### with Terraform

```terraform
module "gcp_gateway_policy" {
  source = "github.com/YpNo/terraform-kubernetes-objects//modules/gke-objects/gcp_gateway_policy?ref=v0.1.0"

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
