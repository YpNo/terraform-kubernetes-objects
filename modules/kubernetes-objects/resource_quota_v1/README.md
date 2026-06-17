# Resource Quota module

Manages namespaced **ResourceQuota** objects (`kubernetes_resource_quota_v1`) capping aggregate resource usage in a namespace. One ResourceQuota per entry via `for_each`.

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
| [kubernetes_resource_quota_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/resource_quota_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_resource_quotas"></a> [resource\_quotas](#input\_resource\_quotas) | A list of Kubernetes ResourceQuota configurations. | <pre>list(object({<br/>    name        = string<br/>    namespace   = string<br/>    labels      = optional(map(string), {}) # Labels for the ResourceQuota metadata<br/>    annotations = optional(map(string), {}) # Annotations for the ResourceQuota metadata<br/><br/>    # The set of desired hard limits for each named resource,<br/>    # e.g. { "requests.cpu" = "4", "pods" = "10" }.<br/>    hard = optional(map(string), {})<br/><br/>    # A collection of filters that must match each object tracked by the quota,<br/>    # e.g. ["BestEffort", "NotTerminating"].<br/>    scopes = optional(list(string), [])<br/><br/>    # Filters expressed using a scope selector operator and possible values.<br/>    scope_selector = optional(object({<br/>      match_expressions = optional(list(object({<br/>        scope_name = string                     # e.g. "PriorityClass", "Terminating"<br/>        operator   = string                     # "In", "NotIn", "Exists", "DoesNotExist"<br/>        values     = optional(list(string), []) # Required for In/NotIn; empty for Exists/DoesNotExist<br/>      })), [])<br/>    }))<br/>  }))</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage

```terraform
...

  inputs = {
    resource_quotas = [
      {
        name      = "team-a-compute"
        namespace = "team-a"
        labels = {
          "app.kubernetes.io/component" = "resource-quota"
        }

        # Aggregate hard limits enforced across the namespace
        hard = {
          "requests.cpu"    = "4"
          "requests.memory" = "8Gi"
          "limits.cpu"      = "8"
          "limits.memory"   = "16Gi"
          "pods"            = "20"
          "services"        = "10"
        }

        # Only count long-running (non-terminating) workloads
        scopes = ["NotTerminating"]

        # Restrict the quota to a given priority class
        scope_selector = {
          match_expressions = [
            {
              scope_name = "PriorityClass"
              operator   = "In"
              values     = ["high"]
            }
          ]
        }
      }
    ]
  }
```
