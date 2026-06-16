resource "kubernetes_service_v1" "this" {
  for_each = { for s in var.services : s.name => s }

  metadata {
    name        = each.value.name
    namespace   = each.value.namespace
    annotations = each.value.annotations
    labels      = each.value.labels
  }
  spec {
    load_balancer_ip                  = each.value.type == "LoadBalancer" ? each.value.load_balancer_ip : null
    allocate_load_balancer_node_ports = each.value.type == "LoadBalancer" ? true : null

    dynamic "port" {
      for_each = each.value.ports

      content {
        name        = port.value.name
        port        = port.value.port
        protocol    = port.value.protocol
        target_port = port.value.target_port
      }
    }

    selector = each.value.selector
    type     = each.value.type
  }

  wait_for_load_balancer = each.value.type == "LoadBalancer" ? true : false

  lifecycle {
    ignore_changes = [
      metadata[0].annotations["cloud.google.com/neg-status"]
    ]
  }
}
