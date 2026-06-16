resource "kubernetes_persistent_volume_claim" "this" {
  for_each = { for pvc in var.persistent_volume_claims : "${pvc.namespace}/${pvc.name}" => pvc }

  metadata {
    name        = each.value.name
    namespace   = each.value.namespace
    labels      = try(each.value.labels, {})
    annotations = try(each.value.annotations, {})
  }

  spec {
    access_modes = each.value.access_modes

    resources {
      requests = {
        storage = each.value.storage_request
      }
    }

    storage_class_name = try(each.value.storage_class_name, null)
    volume_name        = try(each.value.volume_name, null)
    volume_mode        = try(each.value.volume_mode, "Filesystem")

    dynamic "selector" {
      for_each = try(each.value.selector, null) != null ? [each.value.selector] : []
      content {
        match_labels = try(selector.value.match_labels, null)

        dynamic "match_expressions" {
          for_each = try(selector.value.match_expressions, [])
          content {
            key      = match_expressions.value.key
            operator = match_expressions.value.operator
            values   = match_expressions.value.values
          }
        }
      }
    }
  }

  timeouts {
    create = try(var.timeouts.create, null)
  }
}