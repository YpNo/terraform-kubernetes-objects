# CSI Driver v1 module

Manages **CSIDriver** objects (`kubernetes_csi_driver_v1`) describing how a CSI storage driver integrates with the cluster. Cluster-scoped; one CSIDriver per entry via `for_each`.

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
| [kubernetes_csi_driver_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/csi_driver_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_csi_drivers"></a> [csi\_drivers](#input\_csi\_drivers) | A list of Kubernetes CSIDriver configurations. CSIDriver is a cluster-scoped object that captures information about a Container Storage Interface (CSI) volume driver deployed on the cluster. | <pre>list(object({<br/>    name        = string<br/>    labels      = optional(map(string), {}) # Labels for the CSIDriver metadata<br/>    annotations = optional(map(string), {}) # Annotations for the CSIDriver metadata<br/><br/>    spec = object({<br/>      # attach_required indicates if the CSI volume driver requires an attach operation.<br/>      attach_required = bool<br/>      # pod_info_on_mount indicates the driver requires additional pod information (podName, podUID, etc.) during mount.<br/>      pod_info_on_mount = optional(bool)<br/>      # volume_lifecycle_modes defines what kind of volumes this driver supports. Valid values: "Persistent", "Ephemeral".<br/>      volume_lifecycle_modes = optional(list(string), [])<br/>    })<br/>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage

### with Terraform

```terraform
module "csi_driver_v1" {
  source = "github.com/YpNo/terraform-kubernetes-objects//modules/kubernetes-objects/csi_driver_v1?ref=v0.1.0"

...

  csi_drivers = [
    {
      name = "csi.example.com"
      spec = {
        attach_required        = true
        pod_info_on_mount      = true
        volume_lifecycle_modes = ["Persistent", "Ephemeral"]
      }
    }
  ]
}
```

### with Terragrunt

```terraform
...

inputs = {
...

  csi_drivers = [
    {
      name = "csi.example.com"
      spec = {
        attach_required        = true
        pod_info_on_mount      = true
        volume_lifecycle_modes = ["Persistent", "Ephemeral"]
      }
    }
  ]
}
```
