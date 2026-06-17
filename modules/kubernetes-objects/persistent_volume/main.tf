locals {
  claims = {
    for name, pv in var.persistent_volumes : name => pv
    if try(pv.claim, null) != null
  }
}

resource "kubernetes_persistent_volume" "this" {
  for_each = { for pv in var.persistent_volumes : pv.name => pv }

  metadata {
    name        = each.value.name
    labels      = each.value.labels
    annotations = each.value.annotations
  }

  spec {
    capacity = {
      storage = each.value.capacity
    }

    access_modes = each.value.access_modes
    persistent_volume_source {
      dynamic "gce_persistent_disk" {
        for_each = try(each.value.persistent_volume_source.gce_persistent_disk, null) != null ? [each.value.persistent_volume_source.gce_persistent_disk] : []
        content {
          pd_name   = gce_persistent_disk.value.pd_name
          fs_type   = try(gce_persistent_disk.value.fs_type, "ext4")
          read_only = try(gce_persistent_disk.value.read_only, false)
        }
      }

      dynamic "aws_elastic_block_store" {
        for_each = try(each.value.persistent_volume_source.aws_elastic_block_store, null) != null ? [each.value.persistent_volume_source.aws_elastic_block_store] : []
        content {
          volume_id = aws_elastic_block_store.value.volume_id
          fs_type   = try(aws_elastic_block_store.value.fs_type, "ext4")
          read_only = try(aws_elastic_block_store.value.read_only, false)
        }
      }

      dynamic "azure_disk" {
        for_each = try(each.value.persistent_volume_source.azure_disk, null) != null ? [each.value.persistent_volume_source.azure_disk] : []
        content {
          caching_mode  = azure_disk.value.caching_mode
          disk_name     = azure_disk.value.disk_name
          data_disk_uri = azure_disk.value.data_disk_uri
          kind          = try(azure_disk.value.kind, "Managed")
          fs_type       = try(azure_disk.value.fs_type, "ext4")
          read_only     = try(azure_disk.value.read_only, false)
        }
      }

      dynamic "nfs" {
        for_each = try(each.value.persistent_volume_source.nfs, null) != null ? [each.value.persistent_volume_source.nfs] : []
        content {
          server    = nfs.value.server
          path      = nfs.value.path
          read_only = try(nfs.value.read_only, false)
        }
      }

      dynamic "csi" {
        for_each = try(each.value.persistent_volume_source.csi, null) != null ? [each.value.persistent_volume_source.csi] : []
        content {
          driver            = csi.value.driver
          volume_handle     = csi.value.volume_handle
          read_only         = try(csi.value.read_only, false)
          fs_type           = try(csi.value.fs_type, "ext4")
          volume_attributes = try(csi.value.volume_attributes, {})
        }
      }

      dynamic "local" {
        for_each = try(each.value.persistent_volume_source.local, null) != null ? [each.value.persistent_volume_source.local] : []
        content {
          path = local.value.path
        }
      }
    }

    persistent_volume_reclaim_policy = try(each.value.reclaim_policy, "Retain")
    storage_class_name               = each.value.storage_class_name
    volume_mode                      = each.value.volume_mode

    dynamic "claim_ref" {
      for_each = try(each.value.claim_ref, null) != null ? [each.value.claim_ref] : []
      content {
        name      = claim_ref.value.name
        namespace = claim_ref.value.namespace
      }
    }

    dynamic "node_affinity" {
      for_each = try(each.value.node_affinity, null) != null ? [each.value.node_affinity] : []
      content {
        dynamic "required" {
          for_each = try(node_affinity.value.required, null) != null ? [node_affinity.value.required] : []
          content {
            dynamic "node_selector_term" {
              for_each = required.value.node_selector_terms
              content {
                dynamic "match_expressions" {
                  for_each = node_selector_term.value.match_expressions
                  content {
                    key      = match_expressions.value.key
                    operator = match_expressions.value.operator
                    values   = match_expressions.value.values
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

module "claims" {
  source   = "../persistent_volume_claim"
  for_each = local.claims

  persistent_volume_claims = [
    {
      name      = each.key
      namespace = each.value.claim.namespace

      labels             = each.value.labels
      storage_request    = try(each.value.claim.storage_request, each.value.capacity)
      access_modes       = each.value.access_modes
      volume_name        = each.key
      storage_class_name = ""
    }
  ]
}
