resource "kubernetes_storage_class" "this" {
  for_each = { for sc in var.storage_classes : sc.name => sc }

  metadata {
    name = each.value.name
  }

  storage_provisioner = each.value.storage_provisioner
  reclaim_policy      = each.value.reclaim_policy

  parameters = {
    type = each.value.storage_type
  }

  mount_options = each.value.mount_options
}