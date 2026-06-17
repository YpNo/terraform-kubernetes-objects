# Cluster Role module

Manages **ClusterRole** RBAC objects (`kubernetes_cluster_role_v1`) — cluster-scoped permission sets. Creates one ClusterRole per entry in its `list(object)` input via `for_each`.

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
| [kubernetes_cluster_role_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_roles"></a> [cluster\_roles](#input\_cluster\_roles) | A list of Kubernetes Role configurations. | <pre>list(object({<br>    name = string<br>    rules = list(object({<br>      api_groups     = optioan(list(string))<br>      resources      = optional(list(string))<br>      resource_names = optional(list(string), []) # resource_names are optional<br>      verbs          = list(string)<br>    }))<br>  }))</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with Terragrunt

```terraform
...

inputs = { 
  cluster_roles = [
    {
      name      = "pod-reader"
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
