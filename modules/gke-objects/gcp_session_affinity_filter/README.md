# GCPSessionAffinityFilter module
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
| <a name="input_gcp_session_affinity_filters"></a> [gcp\_session\_affinity\_filters](#input\_gcp\_session\_affinity\_filters) | A list of GCPSessionAffinityFilter configurations. Referenced by an HTTPRoute extensionRef filter rather than attached via targetRef. | <pre>list(object({<br/>    name        = string<br/>    namespace   = optional(string, "istio-system")<br/>    labels      = optional(map(string))<br/>    annotations = optional(map(string))<br/>    # spec.statefulGeneratedCookie - stateful cookie-based session affinity.<br/>    stateful_generated_cookie = object({<br/>      cookie_ttl_seconds = number # 1-86400<br/>    })<br/>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with Terragrunt

```terraform
...

inputs = {
  gcp_session_affinity_filters = [
    {
      name      = "store-affinity-filter"
      namespace = "default"
      stateful_generated_cookie = {
        cookie_ttl_seconds = 3600
      }
    }
  ]
}
```

The filter is referenced from an HTTPRoute rule via an `extensionRef` filter
(`group: networking.gke.io`, `kind: GCPSessionAffinityFilter`), not attached
through a `targetRef`.
