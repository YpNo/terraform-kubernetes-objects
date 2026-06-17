# Persistent Volume Claim

> **Deprecated:** use the [`persistent_volume_claim_v1`](../persistent_volume_claim_v1) module instead. This alias targets the provider's non-versioned resource name and is kept only for backward compatibility; it will be removed in a future major release.
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
| [kubernetes_persistent_volume_claim.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/persistent_volume_claim) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_persistent_volume_claims"></a> [persistent\_volume\_claims](#input\_persistent\_volume\_claims) | A list of Kubernetes Persistent Volume Claims to create. | <pre>list(object({<br>    name               = string<br>    namespace          = string<br>    labels             = optional(map(string))<br>    annotations        = optional(map(string))<br>    access_modes       = list(string)<br>    storage_request    = string # e.g., "10Gi", "1Ti"<br>    storage_class_name = optional(string)<br>    volume_name        = optional(string)<br>    volume_mode        = optional(string, "Filesystem")<br><br>    selector = optional(object({<br>      match_labels = optional(map(string))<br>      match_expressions = optional(list(object({<br>        key      = string<br>        operator = string<br>        values   = list(string)<br>      })))<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | An optional timeout block for creating the resource. | <pre>object({<br>    create = optional(string)<br>  })</pre> | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with Terragrunt

```terraform
...

inputs = {
...

  persistent_volume_claims = [
    # --- Example 1: Dynamic Provisioning ---
    # This PVC will ask the 'standard-rwo' storage class to create a new PV for it.
    {
      name               = "dynamic-pvc-example"
      namespace          = "default"
      access_modes       = ["ReadWriteOnce"]
      storage_request    = "5Gi"
      storage_class_name = "standard-rwo"
      labels = {
        "app" = "my-database"
      }
    },

    # --- Example 2: Binding to a Specific PV ---
    # This PVC will not use a storage class and will bind directly to the PV named 'nfs-share-pv'.
    {
      name            = "static-pvc-example"
      namespace       = "production"
      access_modes    = ["ReadWriteMany"]
      storage_request = "100Gi" # This must be less than or equal to the PV's capacity
      volume_name     = "nfs-share-pv"
    }
  ]
}
```
