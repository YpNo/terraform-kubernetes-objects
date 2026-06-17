# Compute Class module for GKE
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
| <a name="input_compute_classes"></a> [compute\_classes](#input\_compute\_classes) | A list of ComputeClass objects to create. | <pre>list(object({<br/>    name        = string<br/>    namespace   = optional(string)<br/>    labels      = optional(map(string))<br/>    annotations = optional(map(string))<br/>    active_migration = optional(object({<br/>      optimizeRulePriority = optional(bool)<br/>      whenUnsatisfiable    = optional(string)<br/>    }))<br/>    autoscaling_policy = optional(object({<br/>      consolidation_delay_minutes = optional(number)<br/>      consolidation_threshold     = optional(number)<br/>      gpu_consolidation_threshold = optional(number)<br/>    }), {})<br/>    node_pool_auto_creation_enabled = optional(bool, true)<br/>    priority_defaults = optional(object({<br/>      machine_family = optional(string)<br/>      machine_type   = optional(string)<br/>      location       = optional(string)<br/>      min_cores      = optional(number)<br/>      min_memory_gb  = optional(number)<br/>      spot           = optional(bool)<br/>    }), {})<br/>    priorities = list(object({<br/>      machine_family = optional(string)<br/>      machine_type   = optional(string)<br/>      location       = optional(string)<br/>      min_cores      = optional(number)<br/>      min_memory_gb  = optional(number)<br/>      spot           = optional(bool)<br/>      flex_start     = optional(bool)         # request short-lived nodes provisioned via DWS Flex-start<br/>      priority_score = optional(number)       # relative priority score for this rule<br/>      nodepools      = optional(list(string)) # GKE Standard: existing node pool names to select<br/>      gpu = optional(object({<br/>        type  = string<br/>        count = number<br/>      }))<br/>      reservations = optional(object({<br/>        affinity = string # ANY_RESERVATION | SPECIFIC_RESERVATION | NO_RESERVATION<br/>        specific = optional(list(object({<br/>          name              = string<br/>          reservation_block = optional(string)<br/>        })))<br/>      }))<br/>    }))<br/>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with terraform

```terraform
...

module "compute_class" {
  source = "./modules/gke-compute-class"

  compute_classes = [
    {
      name      = "general-purpose"
      namespace = "default"
      labels = {
        "class-type" = "general"
      }
      autoscaling_policy = {
        consolidationDelayMinutes = 10
        consolidationThreshold    = 70
      }
      priorities = [
        {
          machine_family = "n2"
          spot           = true
        },
        {
          machine_family = "n2d"
          spot           = true
        },
        {
          machine_family = "n2"
          spot           = false
        }
      ]
    },
    {
      name      = "gpu-optimized"
      namespace = "gpu-workloads"
      labels = {
        "class-type" = "gpu"
      }
      active_migration = {
        optimizeRulePriority = true
      }
      priorities = [
        {
          machine_type = "g2-standard-4"
          spot         = true
          gpu = {
            type  = "nvidia-l4"
            count = 1
          }
        },
        {
          machine_type = "g2-standard-8"
          spot         = false
          gpu = {
            type  = "nvidia-l4"
            count = 1
          }
        }
      ]
    }
  ]
}
```
