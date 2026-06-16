# Namespace module
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
| [kubernetes_namespace.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_namespaces"></a> [namespaces](#input\_namespaces) | A list Map of Namespace objects to create.<br>Each object must have the following attributes:<br>  - name: (string, required) The name of the namespace.<br>  - labels: (object(string), required) Defines labels to add in the namespace.<br>  - annotations: (object(string), optional) Defines Defines annotations you want to set in the namespace. Defaults to '{}'. | <pre>list(object({<br>    name        = string<br>    labels      = optional(map(string))<br>    annotations = optional(map(string))<br>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with Terragrunt

```terraform
...

inputs = {
  namespaces = [
    {
      name = "my-application"
      labels = {
        "app.kubernetes.io/part-of" = "my-application-suite"
        "environment"               = "production"
      }
      annotations = {
        "argocd.argoproj.io/sync-wave" = "0"
        "team-lead"                    = "alice.smith@example.com"
      }
    },
    {
      name = "monitoring"
      labels = {
        "component" = "monitoring"
      }
      # No annotations for this namespace, defaults to {}
    },
    {
      name = "staging"
      labels = {
        "environment" = "staging"
      }
      annotations = {
        "description" = "Staging environment for testing new features"
      }
    }
  ]
}
```
