# Priority Class

> **Deprecated:** use the [`priorityclass_v1`](../priorityclass_v1) module instead. This alias targets the provider's non-versioned resource name and is kept only for backward compatibility; it will be removed in a future major release.

Manages cluster-scoped **PriorityClass** objects mapping a name to a scheduling priority value. One PriorityClass per entry via `for_each`.

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
| [kubernetes_priority_class.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/priority_class) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_priority_classes"></a> [priority\_classes](#input\_priority\_classes) | A map of PriorityClass objects to create.<br>The keys of the map will be used as the Terraform resource instance keys.<br>Each object in the map must have the following attributes:<br>  - name: (string, required) The name of the PriorityClass. Must be a valid DNS subdomain name.<br>  - labels: (map(string), optional) The labels applied to the resource<br>  - annotations: (map(string)) The resource's annotations<br>  - value: (number, required) The integer value of this priority class. Higher values mean higher priority. Must be >= 0 and <= 1,000,000,000.<br>  - description: (string, optional) An arbitrary string that usually provides human-readable guidance on when this PriorityClass should be used.<br>  - global\_default: (bool, optional) Specifies if this PriorityClass should be the default for pods without a priority class. Only one can be true cluster-wide. Defaults to false.<br>  - preemption\_policy: (string, optional) Specifies the policy for preempting pods with lower priority. Valid values are 'PreemptLowerPriority' or 'Never'. Defaults to 'PreemptLowerPriority'. | <pre>list(object({<br>    name              = string<br>    labels            = optional(map(string))<br>    annotations       = optional(map(string))<br><br>    value             = number<br>    description       = optional(string)<br>    global_default    = optional(bool, false)<br>    preemption_policy = optional(string, "PreemptLowerPriority") # Default to Kubernetes default if not specified<br>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with Terragrunt

```terraform
...

inputs = {
...

  priority_classes = [
    {
      name        = "critical-system-priority"
      value       = 1000000 # High priority
      description = "For critical cluster components, allows preemption."
    },
    {
      name           = "high-priority-app"
      value          = 500000
      description    = "For important applications, can preempt lower priority pods."
      labels         = { priority = "high" }
      annotations    = { "components.gke.io/component-name" = "managed-prometheus" }
      global_default = false
    },
    {
      name              = "batch-job-priority"
      value             = 100
      description       = "For batch jobs that should not preempt other pods."
      global_default    = false
      preemption_policy = "Never" # This ensures it won't preempt
    },
    {
      name           = "default-global-priority"
      value          = 0 # Lowest priority
      description    = "Default priority for pods that do not specify a priorityClass."
      global_default = true # This will be the cluster-wide default
    }
  ]
}
```
