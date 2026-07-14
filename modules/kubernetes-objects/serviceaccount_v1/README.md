# Service Account module for v1 version of kubernetes Module

Manages namespaced **ServiceAccount** objects (`kubernetes_service_account_v1`) providing workload identities. One per entry via `for_each`.

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
| [kubernetes_service_account_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_service_accounts"></a> [service\_accounts](#input\_service\_accounts) | A list of Kubernetes Service Account configurations. | <pre>list(object({<br/>    name                            = string<br/>    namespace                       = string<br/>    annotations                     = optional(map(string), {}) # Annotations for the Service Account<br/>    labels                          = optional(map(string), {}) # Labels for the Service Account<br/>    automount_service_account_token = optional(bool, true)      # Whether to automount the API credentials. Defaults to true.<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_service_accounts"></a> [service\_accounts](#output\_service\_accounts) | Map of created ServiceAccounts keyed by name. Reference name/namespace from a pod's service\_account\_name or a RoleBinding subject. |
<!-- END_TF_DOCS -->

## Usage

### with Terraform

```terraform
module "serviceaccount_v1" {
  source = "github.com/YpNo/terraform-kubernetes-objects//modules/kubernetes-objects/serviceaccount_v1?ref=v0.1.0"

  service_accounts = [
    {
      name        = "my-app-sa"
      namespace   = "default"
      annotations = {
        "eks.amazonaws.com/role-arn" = "arn:aws:iam::123456789012:role/my-app-iam-role"
      }
      labels = {
        "app.kubernetes.io/component" = "backend"
      }
      automount_service_account_token = true
    },
    {
      name        = "cronjob-sa"
      namespace   = "batch-jobs"
      automount_service_account_token = false # For security, if token isn't needed
    }
  ]
}
```

### with Terragrunt

```terraform
...

inputs = {
  service_accounts = [
    {
      name        = "my-app-sa"
      namespace   = "default"
      annotations = {
        "eks.amazonaws.com/role-arn" = "arn:aws:iam::123456789012:role/my-app-iam-role"
      }
      labels = {
        "app.kubernetes.io/component" = "backend"
      }
      automount_service_account_token = true
    },
    {
      name        = "cronjob-sa"
      namespace   = "batch-jobs"
      automount_service_account_token = false # For security, if token isn't needed
    }
  ]
}
```
