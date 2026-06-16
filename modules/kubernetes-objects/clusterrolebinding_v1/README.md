# Cluster Role Bindings module

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
| [kubernetes_cluster_role_binding_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_role_bindings"></a> [cluster\_role\_bindings](#input\_cluster\_role\_bindings) | A list of Kubernetes RoleBinding configurations. | <pre>list(object({<br>    name = string<br>    role_ref = object({<br>      api_group = string # e.g., "rbac.authorization.k8s.io"<br>      kind      = string # "Role" or "ClusterRole"<br>      name      = string # Name of the Role or ClusterRole being bound<br>    })<br>    subjects = list(object({<br>      kind      = string           # "ServiceAccount", "User", or "Group"<br>      name      = string           # Name of the ServiceAccount, User, or Group<br>      api_group = optional(string) # e.g., "rbac.authorization.k8s.io" for User/Group, "" for ServiceAccount<br>      namespace = optional(string) # Required for ServiceAccount kind<br>    }))<br>  }))</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with Terragrunt

```terraform
...

inputs = { 
    cluster_role_bindings = [
    {
      name      = "helm-read-binding"
      role_ref = {
        api_group = "rbac.authorization.k8s.io"
        kind      = "Role"
        name      = "pod-reader" # Assumes a Role named 'pod-reader' exists in default' namespace
      }
      subjects = [{
        kind      = "ServiceAccount"
        name      = "helm"
        namespace = "default"
        api_group = "" # Core API group for ServiceAccounts
      }]
    },
    {
      name      = "admin-user-binding"
      role_ref = {
        api_group = "rbac.authorization.k8s.io"
        kind      = "ClusterRole"
        name      = "cluster-admin"
      }
      subjects = [
        {
          kind      = "User"
          name      = "toto@example.com"
          api_group = "rbac.authorization.k8s.io"
        },
        {
          kind      = "Group"
          name      = "devops-admins@example.com"
          api_group = "rbac.authorization.k8s.io"
        },
      ]
    }
  ]
}
```
