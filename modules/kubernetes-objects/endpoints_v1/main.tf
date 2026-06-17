resource "kubernetes_endpoints_v1" "this" {
  for_each = { for e in var.endpoints : e.name => e }

  metadata {
    name        = each.value.name
    namespace   = each.value.namespace
    labels      = each.value.labels
    annotations = each.value.annotations
  }

  dynamic "subset" {
    for_each = each.value.subsets

    content {
      dynamic "address" {
        for_each = subset.value.address

        content {
          ip        = address.value.ip
          hostname  = address.value.hostname
          node_name = address.value.node_name
        }
      }

      dynamic "not_ready_address" {
        for_each = subset.value.not_ready_address

        content {
          ip        = not_ready_address.value.ip
          hostname  = not_ready_address.value.hostname
          node_name = not_ready_address.value.node_name
        }
      }

      dynamic "port" {
        for_each = subset.value.port

        content {
          name     = port.value.name
          port     = port.value.port
          protocol = port.value.protocol
        }
      }
    }
  }
}
