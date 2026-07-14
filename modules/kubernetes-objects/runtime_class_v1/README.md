# Runtime Class v1 module

Manages cluster-scoped **RuntimeClass** objects (`kubernetes_runtime_class_v1`) selecting the container runtime configuration for pods. One per entry via `for_each`.

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
| [kubernetes_runtime_class_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/runtime_class_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_runtime_classes"></a> [runtime\_classes](#input\_runtime\_classes) | A list of Kubernetes RuntimeClass configurations. RuntimeClass is a cluster-scoped resource used to select the container runtime configuration that is used to run a Pod's containers. | <pre>list(object({<br/>    name        = string<br/>    labels      = optional(map(string), {}) # Labels for the RuntimeClass metadata<br/>    annotations = optional(map(string), {}) # Annotations for the RuntimeClass metadata<br/><br/>    # handler specifies the underlying runtime and configuration that the CRI<br/>    # implementation will use to handle pods of this class. Must be a valid DNS label.<br/>    handler = string<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_runtime_classes"></a> [runtime\_classes](#output\_runtime\_classes) | Map of created RuntimeClasses keyed by name. Reference the name from a pod's runtime\_class\_name. |
<!-- END_TF_DOCS -->

## Usage

### with Terraform

```terraform
module "runtime_class_v1" {
  source = "github.com/YpNo/terraform-kubernetes-objects//modules/kubernetes-objects/runtime_class_v1?ref=v0.1.0"

...

  runtime_classes = [
    {
      name    = "gvisor"
      handler = "runsc"
    },
    {
      name    = "kata"
      handler = "kata-runtime"
      labels  = { tier = "isolated" }
    }
  ]
}
```

### with Terragrunt

```terraform
...

inputs = {
...

  runtime_classes = [
    {
      name    = "gvisor"
      handler = "runsc"
    },
    {
      name    = "kata"
      handler = "kata-runtime"
      labels  = { tier = "isolated" }
    }
  ]
}
```
