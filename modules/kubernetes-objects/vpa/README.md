# Vertical Pod Autoscaling module
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.37.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.37.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_manifest.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_vpas"></a> [vpas](#input\_vpas) | A list of Vertical Pod Autoscaler (VPA) configurations. | <pre>list(object({<br>    name        = string<br>    namespace   = string<br>    labels      = optional(map(string), {})<br>    annotations = optional(map(string), {})<br><br>    target_ref = object({<br>      api_version = string # e.g., "apps/v1", "batch/v1"<br>      kind        = string # e.g., "Deployment", "StatefulSet", "DaemonSet", "Job"<br>      name        = string<br>    })<br><br>    update_policy = optional(object({<br>      # "Off", "Initial", "Recreate", "Auto"<br>      # "Auto" is currently equivalent to "Recreate" and can cause pod restarts.<br>      # "Initial" is often preferred with HPA.<br>      update_mode = string<br>    }))<br><br>    resource_policy = optional(object({<br>      container_policies = list(object({<br>        container_name       = string                                    # "*" for all containers, or specific container name<br>        mode                 = optional(string, "Auto")                  # "Off" or "Auto" for individual container policy<br>        controlled_resources = optional(list(string), ["cpu", "memory"]) # e.g., ["cpu", "memory"]<br>        value_type           = optional(string, "RequestsAndLimits")     # "RequestsOnly" or "RequestsAndLimits"<br><br>        min_allowed = optional(map(string), {}) # e.g., { "cpu" = "100m", "memory" = "50Mi" }<br>        max_allowed = optional(map(string), {}) # e.g., { "cpu" = "2", "memory" = "4Gi" }<br>      }))<br>    }))<br><br>    recommender_policy = optional(object({<br>      recommenders = list(object({<br>        name = string # Name of the recommender to use (e.g., "default")<br>      }))<br>    }))<br>  }))</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with Terragrunt

```terraform
...

inputs = {
  vpas = [
    {
      name        = "my-app-vpa"
      namespace   = "default"
      labels      = { "app" = "my-app" }
      target_ref = {
        api_version = "apps/v1"
        kind        = "Deployment"
        name        = "my-app-deployment"
      }
      update_policy = {
        update_mode = "Auto"
      }
      resource_policy = {
        container_policies = [
          {
            container_name = "*" # Apply to all containers in the pod
            min_allowed = {
              "cpu"    = "100m"
              "memory" = "50Mi"
            }
            max_allowed = {
              "cpu"    = "2"
              "memory" = "4Gi"
            }
            controlled_resources = ["cpu", "memory"]
            value_type = "RequestsAndLimits"
          }
        ]
      }
      recommender_policy = {
        recommenders = [{
          name = "default"
        }]
      }
    },
    {
      name        = "job-vpa"
      namespace   = "batch"
      target_ref = {
        api_version = "batch/v1"
        kind        = "Job"
        name        = "my-batch-job"
      }
      update_policy = {
        update_mode = "Initial" # Only set resources at pod creation
      }
      resource_policy = {
        container_policies = [
          {
            container_name = "worker-container"
            min_allowed = {
              "memory" = "1Gi"
            }
            controlled_resources = ["memory"]
            value_type = "RequestsOnly"
          }
        ]
      }
    }
  ]
}
```
