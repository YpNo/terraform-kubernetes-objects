resource "kubernetes_service_account_v1" "this" {
  for_each = { for sa in var.service_accounts : sa.name => sa }

  metadata {
    name        = each.value.name
    namespace   = each.value.namespace
    annotations = each.value.annotations
    labels      = each.value.labels
  }

  automount_service_account_token = each.value.automount_service_account_token
}
