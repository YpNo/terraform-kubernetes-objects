# API Service v1 module
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
| [kubernetes_api_service_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/api_service_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_api_services"></a> [api\_services](#input\_api\_services) | A list of Kubernetes APIService configurations. APIService is a cluster-scoped resource that registers an API group/version with the aggregation layer, describing how to locate and communicate with the backing server. | <pre>list(object({<br/>    name        = string<br/>    labels      = optional(map(string), {}) # Labels for the APIService metadata<br/>    annotations = optional(map(string), {}) # Annotations for the APIService metadata<br/><br/>    spec = object({<br/>      # group is the API group name this server hosts.<br/>      group = string<br/>      # group_priority_minimum is the minimum priority this group should have. Higher means preferred by clients.<br/>      group_priority_minimum = number<br/>      # version is the API version this server hosts (e.g. "v1").<br/>      version = string<br/>      # version_priority controls ordering of this version inside its group. Must be greater than zero.<br/>      version_priority = number<br/>      # ca_bundle is a PEM encoded CA bundle used to validate the API server's serving certificate.<br/>      ca_bundle = optional(string)<br/>      # insecure_skip_tls_verify disables TLS certificate verification. Strongly discouraged; prefer ca_bundle.<br/>      insecure_skip_tls_verify = optional(bool)<br/>      # service references the backing service. Omit for an API group/version handled locally on this server.<br/>      service = optional(object({<br/>        name      = string<br/>        namespace = string<br/>        port      = optional(number) # Defaults to 443. Valid range 1-65535.<br/>      }))<br/>    })<br/>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with Terragrunt

```terraform
...

inputs = {
...

  api_services = [
    {
      name = "v1beta1.metrics.k8s.io"
      spec = {
        group                    = "metrics.k8s.io"
        group_priority_minimum   = 100
        version                  = "v1beta1"
        version_priority         = 100
        insecure_skip_tls_verify = true
        service = {
          name      = "metrics-server"
          namespace = "kube-system"
        }
      }
    }
  ]
}
```
