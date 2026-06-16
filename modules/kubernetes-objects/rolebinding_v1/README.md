# Role Bindings module for v1 version of kubernetes API
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
| [kubernetes_role_binding_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_binding_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_role_bindings"></a> [role\_bindings](#input\_role\_bindings) | A list of Kubernetes RoleBinding configurations. | <pre>list(object({<br>    name      = string<br>    namespace = string<br>    role_ref = object({<br>      api_group = string # e.g., "rbac.authorization.k8s.io"<br>      kind      = string # "Role" or "ClusterRole"<br>      name      = string # Name of the Role or ClusterRole being bound<br>    })<br>    subject = object({<br>      kind      = string           # "ServiceAccount", "User", or "Group"<br>      name      = string           # Name of the ServiceAccount, User, or Group<br>      api_group = optional(string) # e.g., "rbac.authorization.k8s.io" for User/Group, "" for ServiceAccount<br>      namespace = optional(string) # Required for ServiceAccount kind<br>    })<br>  }))</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with Terragrunt

```terraform
...

inputs = {
  role_bindings = [
    {
      name      = "helm-read-binding"
      namespace = "default"
      role_ref = {
        api_group = "rbac.authorization.k8s.io"
        kind      = "Role"
        name      = "pod-reader" # Assumes a Role named 'pod-reader' exists in 'default' namespace
      }
      subject = {
        kind      = "ServiceAccount"
        name      = "helm"
        namespace = "default"
        api_group = "" # Core API group for ServiceAccounts
      }
    },
    {
      name      = "admin-user-binding"
      namespace = "kube-system"
      role_ref = {
        api_group = "rbac.authorization.k8s.io"
        kind      = "ClusterRole"
        name      = "cluster-admin" # Binding to a ClusterRole
      }
      subject = {
        kind      = "User"
        name      = "devops-admin@example.com"
        api_group = "rbac.authorization.k8s.io" # For users
      }
    }
  ]
}
```
