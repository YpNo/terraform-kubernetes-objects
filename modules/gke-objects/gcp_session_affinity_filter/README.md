# GCPSessionAffinityFilter module

A GCPSessionAffinityFilter is a GKE Gateway API CRD that defines stateful cookie-based session affinity, referenced from an HTTPRoute rule via an `extensionRef` filter (not attached through a `targetRef`). This module creates one GCPSessionAffinityFilter per entry in the `gcp_session_affinity_filters` list via `for_each`. Because these are rendered with `kubernetes_manifest`, the GKE GCPSessionAffinityFilter CRD must already be installed and the cluster reachable at plan time.

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
| <a name="input_gcp_session_affinity_filters"></a> [gcp\_session\_affinity\_filters](#input\_gcp\_session\_affinity\_filters) | A list of GCPSessionAffinityFilter configurations. Referenced by an HTTPRoute extensionRef filter rather than attached via targetRef. | <pre>list(object({<br/>    name        = string<br/>    namespace   = optional(string, "istio-system")<br/>    labels      = optional(map(string))<br/>    annotations = optional(map(string))<br/>    # spec.statefulGeneratedCookie - stateful cookie-based session affinity.<br/>    stateful_generated_cookie = object({<br/>      cookie_ttl_seconds = number # 1-86400<br/>    })<br/>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage

### with Terraform

```terraform
module "gcp_session_affinity_filter" {
  source = "github.com/YpNo/terraform-kubernetes-objects//modules/gke-objects/gcp_session_affinity_filter?ref=v0.1.0"

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
