# Limit Range module

Manages namespaced **LimitRange** objects (`kubernetes_limit_range_v1`) that set default/min/max resource constraints for pods, containers and PVCs. One LimitRange per entry via `for_each`.

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
| [kubernetes_limit_range_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/limit_range_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_limit_ranges"></a> [limit\_ranges](#input\_limit\_ranges) | A list of Kubernetes LimitRange configurations. | <pre>list(object({<br/>    name        = string<br/>    namespace   = string<br/>    labels      = optional(map(string), {}) # Labels for the LimitRange metadata<br/>    annotations = optional(map(string), {}) # Annotations for the LimitRange metadata<br/><br/>    # The list of limit items enforced in the namespace.<br/>    limits = optional(list(object({<br/>      type                    = string                    # "Pod", "Container" or "PersistentVolumeClaim"<br/>      max                     = optional(map(string), {}) # Max usage constraints by resource name<br/>      min                     = optional(map(string), {}) # Min usage constraints by resource name<br/>      default                 = optional(map(string), {}) # Default limit value when omitted (Container only)<br/>      default_request         = optional(map(string), {}) # Default request value when omitted (Container only)<br/>      max_limit_request_ratio = optional(map(string), {}) # Max ratio of limit to request per resource<br/>    })), [])<br/>  }))</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage

```terraform
...

  inputs = {
    limit_ranges = [
      {
        name      = "team-a-defaults"
        namespace = "team-a"
        labels = {
          "app.kubernetes.io/component" = "limit-range"
        }

        limits = [
          {
            # Default requests/limits applied to containers without them
            type            = "Container"
            default         = { cpu = "200m", memory = "256Mi" }
            default_request = { cpu = "100m", memory = "128Mi" }
            max             = { cpu = "1", memory = "1Gi" }
            min             = { cpu = "50m", memory = "64Mi" }

            # Cap the limit/request ratio to prevent overcommit
            max_limit_request_ratio = { cpu = "4" }
          },
          {
            type = "PersistentVolumeClaim"
            min  = { storage = "1Gi" }
            max  = { storage = "10Gi" }
          }
        ]
      }
    ]
  }
```
