# Horizontal Pod Autoscaler module

Manages **HorizontalPodAutoscaler** objects that scale a workload's replica count on observed metrics. Namespaced; one HPA per entry in its `list(object)` input via `for_each`.

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
| [kubernetes_horizontal_pod_autoscaler_v2.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/horizontal_pod_autoscaler_v2) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_hpas"></a> [hpas](#input\_hpas) | A list of Horizontal Pod Autoscaler (HPA) configurations. | <pre>list(object({<br/>    name               = string<br/>    namespace          = string<br/>    target_kind        = string # e.g., "Deployment", "StatefulSet"<br/>    target_api_version = string # e.g., "apps/v1"<br/>    target_name        = string<br/>    max_replicas       = number<br/>    min_replicas       = optional(number)<br/>    # Deprecated in HPA v2 (but still exists in v2beta2 and earlier, or for simple CPU target)<br/>    # If using custom metrics, you'd define them in the 'metrics' block.<br/>    target_cpu_utilization_percentage = optional(number)<br/><br/>    metrics = optional(list(object({<br/>      type = string # "Resource", "Pods", "Object", "External"<br/><br/>      # Fields for type "Resource"<br/>      resources = optional(list(object({<br/>        name                = string           # "cpu" or "memory"<br/>        type                = string           # "Utilization" or "AverageValue"<br/>        average_utilization = optional(number) # Required for "Utilization"<br/>        average_value       = optional(string) # Required for "AverageValue" (e.g., "100Mi", "1G")<br/>      })), [])<br/><br/>      # Fields for type "Pods" (not directly used in your HPA, but good to include if you might expand)<br/>      # pods = optional(list(object({<br/>      #   metric = object({<br/>      #     name = string<br/>      #     selector = optional(map(string))<br/>      #   })<br/>      #   target = object({<br/>      #     type = string # "AverageValue"<br/>      #     average_value = string<br/>      #   })<br/>      # })), [])<br/><br/>      # Fields for type "Object" (not directly used in your HPA, but good to include if you might expand)<br/>      # object = optional(list(object({<br/>      #   described_object = object({<br/>      #     api_version = string<br/>      #     kind        = string<br/>      #     name        = string<br/>      #   })<br/>      #   metric = object({<br/>      #     name = string<br/>      #     selector = optional(map(string))<br/>      #   })<br/>      #   target = object({<br/>      #     type = string # "Value" or "AverageValue"<br/>      #     value = optional(string)<br/>      #     average_value = optional(string)<br/>      #   })<br/>      # })), [])<br/><br/>      # Fields for type "External"<br/>      externals = optional(list(object({<br/>        metric = object({<br/>          name     = string                # External metric name<br/>          selector = optional(map(string)) # Labels to select objects<br/>        })<br/>        target = object({<br/>          type                = string           # "Value" or "AverageValue"<br/>          value               = optional(string) # For "Value" (e.g., "100m", "1000")<br/>          average_value       = optional(string) # For "AverageValue" (e.g., "100m", "1000")<br/>          average_utilization = optional(number) # This is not standard for external metrics, usually value/averageValue is used. Confirm Kubernetes API.<br/>        })<br/>      })), [])<br/>    })), [])<br/>  }))</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with Terragrunt

```terraform
...

inputs = {
  hpas = [
    {
      name                          = "my-app-hpa"
      namespace                     = "default"
      target_kind                   = "Deployment"
      target_api_version            = "apps/v1"
      target_name                   = "my-app"
      min_replicas                  = 2
      max_replicas                  = 10
      target_cpu_utilization_percentage = 70 # Can be used alone or with 'metrics'
      metrics = [
        {
          type = "Resource"
          resources = [{
            name                = "memory"
            type                = "Utilization"
            average_utilization = 80 # Target 80% memory utilization
          }]
        },
        {
          type = "External"
          externals = [{
            metric = {
              name = "my-custom-qps"
              selector = {
                "environment" = "prod"
              }
            }
            target = {
              type  = "AverageValue"
              average_value = "100" # Target 100 QPS per pod
            }
          }]
        }
      ]
    },
    {
      name                          = "another-app-hpa"
      namespace                     = "backend"
      target_kind                   = "Deployment"
      target_api_version            = "apps/v1"
      target_name                   = "another-app"
      min_replicas                  = 1
      max_replicas                  = 5
      target_cpu_utilization_percentage = 65 # Only CPU scaling
    }
  ]
}
```
