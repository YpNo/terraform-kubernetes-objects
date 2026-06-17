# Role module

> **Deprecated:** use the [`role_v1`](../role_v1) module instead. This alias targets the provider's non-versioned resource name and is kept only for backward compatibility; it will be removed in a future major release.

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
| [kubernetes_role.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_roles"></a> [roles](#input\_roles) | A list of Kubernetes Role configurations. | <pre>list(object({<br>    name      = string<br>    namespace = string<br>    rules = list(object({<br>      api_groups     = list(string)<br>      resources      = list(string)<br>      resource_names = optional(list(string), []) # resource_names are optional<br>      verbs          = list(string)<br>    }))<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_roles"></a> [roles](#output\_roles) | A map of created Kubernetes Role objects, keyed by their name. |
<!-- END_TF_DOCS -->

## Usage
### with Terragrunt

```terraform
...

inputs = {
  roles = [
    {
      name      = "pod-reader"
      namespace = "default"
      rules = [
        {
          api_groups = [""] # "" indicates the core API group
          resources  = ["pods"]
          verbs      = ["get", "watch", "list"]
        },
        {
          api_groups     = ["apps"]
          resources      = ["deployments"]
          resource_names = ["my-app-deployment"]
          verbs          = ["get"]
        }
      ]
    },
    {
      name      = "configmap-editor"
      namespace = "kube-system"
      rules = [
        {
          api_groups = [""]
          resources  = ["configmaps"]
          verbs      = ["get", "update", "patch"]
        }
      ]
    }
  ]
}
```
