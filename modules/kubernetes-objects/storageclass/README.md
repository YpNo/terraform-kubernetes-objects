# Storage Class module

Manages cluster-scoped **StorageClass** objects (`kubernetes_storage_class`) describing dynamic storage provisioners. One StorageClass per entry via `for_each`.

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
| [kubernetes_storage_class.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_storage_classes"></a> [storage\_classes](#input\_storage\_classes) | A map of StorageClass objects to create.<br/>The keys of the map will be used as the Terraform resource instance keys.<br/>Each object in the map must have the following attributes:<br/>  - name: (string, required) The name of the StorageClass. Must be a valid DNS subdomain name.<br/>  - storage\_provisioner: (string, optional) The name of the storage provisioner to use (e.g., 'kubernetes.io/gce-pd', 'ebs.csi.aws.com'). Default to kubernetes.io/gce-pd<br/>  - reclaim\_policy: (string, optional) Defines what happens to the volume when the PVC is deleted. Valid: 'Retain', 'Delete'. Defaults to 'Delete'.<br/>  - storage\_type: (string, optional) Defines the storage type to use. Valid: 'pd-standard', 'pd-balanced', 'pd-ssd'. Defaults to pd-standard.<br/>  - mount\_options: (list(string), optional) A list of mount options for the persistent volumes. Defaults to null. | <pre>list(object({<br/>    name                = string<br/>    storage_provisioner = optional(string, "kubernetes.io/gce-pd")<br/>    reclaim_policy      = optional(string, "Delete")<br/>    storage_type        = optional(string, "pd-standard")<br/>    mount_options       = optional(list(string), null)<br/>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with Terragrunt

```terraform
...

inputs = {
  storage_classes = [
    {
      name                = "standard-gce"
      storage_provisioner = "kubernetes.io/gce-pd" # Explicitly setting, even if it's default
      reclaim_policy      = "Delete"
      storage_type        = "pd-standard"
      # mount_options default to null
    },
    {
      name                = "ssd-gce-retained"
      storage_provisioner = "kubernetes.io/gce-pd"
      reclaim_policy      = "Retain" # Retain the volume after PVC deletion
      storage_type        = "pd-ssd"
      mount_options       = ["discard"] # Example mount option
    },
    {
      name                = "aws-ebs-gp3"
      storage_provisioner = "ebs.csi.aws.com" # Example for AWS EBS CSI driver
      reclaim_policy      = "Delete"
      # storage_type is not directly applicable here unless custom parameters are used
      # If custom parameters are needed, you might need to extend this module
      # or use `kubernetes_manifest` directly for more complex StorageClasses.
    }
  ]
}
```
