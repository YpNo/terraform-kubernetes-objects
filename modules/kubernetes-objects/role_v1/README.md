# Role module for v1 version of kubernetes API

Manages namespaced **Role** RBAC objects (`kubernetes_role_v1`) — permission sets scoped to a namespace. One Role per entry via `for_each`.

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
| [kubernetes_role_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_roles"></a> [roles](#input\_roles) | A list of Kubernetes Role configurations. | <pre>list(object({<br/>    name      = string<br/>    namespace = string<br/>    rules = list(object({<br/>      api_groups     = list(string)<br/>      resources      = list(string)<br/>      resource_names = optional(list(string), []) # resource_names are optional<br/>      verbs          = list(string)<br/>    }))<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_roles"></a> [roles](#output\_roles) | Map of created Roles keyed by name. Reference name/namespace from a RoleBinding roleRef. |
<!-- END_TF_DOCS -->

## Usage

### with Terraform

```terraform
module "role_v1" {
  source = "github.com/YpNo/terraform-kubernetes-objects//modules/kubernetes-objects/role_v1?ref=v0.1.0"

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
