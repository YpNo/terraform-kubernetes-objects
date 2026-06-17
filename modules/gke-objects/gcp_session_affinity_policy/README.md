# GCPSessionAffinityPolicy module
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
| <a name="input_gcp_session_affinity_policies"></a> [gcp\_session\_affinity\_policies](#input\_gcp\_session\_affinity\_policies) | A list of GCPSessionAffinityPolicy configurations. | <pre>list(object({<br/>    name        = string<br/>    namespace   = optional(string, "istio-system")<br/>    labels      = optional(map(string))<br/>    annotations = optional(map(string))<br/>    # spec.statefulGeneratedCookie - stateful cookie-based session affinity.<br/>    stateful_generated_cookie = optional(object({<br/>      cookie_ttl_seconds = number # 1-86400<br/>    }))<br/>    # spec.targetRef - the resource the policy attaches to.<br/>    target_ref = object({<br/>      group     = optional(string, "")<br/>      kind      = optional(string, "Service")<br/>      name      = string<br/>      namespace = optional(string)<br/>    })<br/>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with Terragrunt

```terraform
...

inputs = {
  gcp_session_affinity_policies = [
    {
      name      = "store-affinity"
      namespace = "default"
      stateful_generated_cookie = {
        cookie_ttl_seconds = 3600
      }
      target_ref = {
        kind = "Service"
        name = "store"
      }
    }
  ]
}
```
