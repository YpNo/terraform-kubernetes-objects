resource "kubernetes_csi_driver_v1" "this" {
  for_each = { for d in var.csi_drivers : d.name => d }

  metadata {
    name        = each.value.name
    labels      = each.value.labels
    annotations = each.value.annotations
  }

  spec {
    attach_required        = each.value.spec.attach_required
    pod_info_on_mount      = each.value.spec.pod_info_on_mount
    volume_lifecycle_modes = each.value.spec.volume_lifecycle_modes
  }
}
