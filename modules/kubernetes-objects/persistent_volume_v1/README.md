# Persistent Volume
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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_claims"></a> [claims](#module\_claims) | ../persistent_volume_claim | n/a |

## Resources

| Name | Type |
|------|------|
| [kubernetes_persistent_volume.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/persistent_volume) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_persistent_volumes"></a> [persistent\_volumes](#input\_persistent\_volumes) | A map of Kubernetes Persistent Volumes to create. The map key is used as the PV name. | <pre>map(object({<br>    name        = string<br>    labels      = optional(map(string))<br>    annotations = optional(map(string))<br><br>    capacity = string<br><br>    access_modes       = list(string)<br>    storage_class_name = optional(string)<br>    reclaim_policy     = optional(string, "Retain")<br>    volume_mode        = optional(string, "Filesystem")<br><br>    claim_ref = optional(object({<br>      name      = string<br>      namespace = string<br>    }))<br><br>    node_affinity = optional(object({<br>      required = optional(object({<br>        node_selector_terms = list(object({<br>          match_expressions = list(object({<br>            key      = string<br>            operator = string<br>            values   = list(string)<br>          }))<br>        }))<br>      }))<br>    }))<br><br>    persistent_volume_source = object({<br>      gce_persistent_disk = optional(object({<br>        pd_name   = string<br>        fs_type   = optional(string)<br>        read_only = optional(bool)<br>      }))<br>      aws_elastic_block_store = optional(object({<br>        volume_id = string<br>        fs_type   = optional(string)<br>        read_only = optional(bool)<br>      }))<br>      azure_disk = optional(object({<br>        caching_mode  = string<br>        disk_name     = string<br>        data_disk_uri = string<br>        kind          = optional(string)<br>        fs_type       = optional(string)<br>        read_only     = optional(bool)<br>      }))<br>      nfs = optional(object({<br>        server    = string<br>        path      = string<br>        read_only = optional(bool)<br>      }))<br>      csi = optional(object({<br>        driver            = string<br>        volume_handle     = string<br>        read_only         = optional(bool)<br>        fs_type           = optional(string)<br>        volume_attributes = optional(map(string))<br>      }))<br>      local = optional(object({<br>        path = string<br>      }))<br>    })<br>    claim = optional(object({<br>      namespace          = string<br>      storage_request    = optional(string)<br>    }))<br>  }))</pre> | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with Terragrunt

```terraform
...

inputs = {
...

  persistent_volumes = {
    # This PV will be created WITHOUT a corresponding PVC.
    "shared-logs-pv" = {
      storage_class_name = "slow"
      access_modes       = ["ReadOnlyMany"]
      capacity = {
        storage = "50Gi"
      }
      persistent_volume_source = {
        nfs = {
          server = "10.0.0.5"
          path   = "/exports/logs"
        }
      }
      # No 'create_claim' block is present.
    },

    # This PV WILL have a PVC created for it automatically.
    "mysql-data-pv" = {
      storage_class_name = "fast-ssd"
      access_modes       = ["ReadWriteOnce"]
      capacity = {
        storage = "20Gi"
      }
      persistent_volume_source = {
        gce_persistent_disk = {
          pd_name = "mysql-disk-1"
        }
      }
      # This block triggers the PVC creation.
      create_claim = {
        namespace = "production"
        storage_request = "10Gi" # If different of capacity storage
      }
    }
  }
}
```
