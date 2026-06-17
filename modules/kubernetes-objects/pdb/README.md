# Pod Disruption Budget module

Manages **PodDisruptionBudget** objects that limit voluntary disruptions for a set of pods. Namespaced; one PDB per entry via `for_each`.

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
| [kubernetes_pod_disruption_budget_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/pod_disruption_budget_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_pdbs"></a> [pdbs](#input\_pdbs) | A list of Kubernetes Pod Disruption Budget (PDB) configurations. | <pre>list(object({<br/>    name            = string<br/>    namespace       = string<br/>    labels          = optional(map(string), {}) # Labels for the PDB metadata<br/>    min_available   = optional(string)          # Minimum number/percentage of pods that must be available (e.g., "1", "50%")<br/>    max_unavailable = optional(string)          # Maximum number/percentage of pods that can be unavailable (e.g., "1", "25%")<br/>    selector = object({<br/>      match_labels = map(string)                 # Labels to select pods<br/>      match_expressions = optional(list(object({ # Optional list of label selector requirements<br/>        key      = string<br/>        operator = string                     # e.g., "In", "NotIn", "Exists", "DoesNotExist"<br/>        values   = optional(list(string), []) # Values for In/NotIn operators<br/>      })), [])<br/>    })<br/>  }))</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with Terragrunt

```terraform
...

inputs = {
  pdbs = [
    {
      name             = "my-app-pdb"
      namespace        = "default"
      labels = {
        "app.kubernetes.io/component" = "frontend"
      }
      min_available    = "70%" # At least 70% of pods must be available
      selector = {
        match_labels = {
          "app" = "my-app"
        }
        match_expressions = [
          {
            key      = "environment"
            operator = "In"
            values   = ["prod", "staging"]
          }
        ]
      }
    },
    {
      name             = "database-pdb"
      namespace        = "backend"
      max_unavailable  = "1" # Allow only 1 pod to be unavailable at a time
      selector = {
        match_labels = {
          "app" = "database"
        }
      }
    }
  ]
}
```
