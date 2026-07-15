resource "kubernetes_service_v1" "this" {
  for_each = { for s in var.services : s.name => s }

  metadata {
    name        = each.value.name
    namespace   = each.value.namespace
    annotations = each.value.annotations
    labels      = each.value.labels
  }

  spec {
    type     = each.value.type
    selector = each.value.selector

    cluster_ip       = each.value.cluster_ip
    cluster_ips      = each.value.cluster_ips
    ip_families      = each.value.ip_families
    ip_family_policy = each.value.ip_family_policy

    external_name               = each.value.external_name
    external_ips                = each.value.external_ips
    external_traffic_policy     = each.value.external_traffic_policy
    internal_traffic_policy     = each.value.internal_traffic_policy
    health_check_node_port      = each.value.health_check_node_port
    publish_not_ready_addresses = each.value.publish_not_ready_addresses

    session_affinity = each.value.session_affinity

    load_balancer_ip                  = each.value.load_balancer_ip
    load_balancer_class               = each.value.load_balancer_class
    load_balancer_source_ranges       = each.value.load_balancer_source_ranges
    allocate_load_balancer_node_ports = each.value.allocate_load_balancer_node_ports

    dynamic "port" {
      for_each = each.value.ports

      content {
        name         = port.value.name
        port         = port.value.port
        protocol     = port.value.protocol
        target_port  = port.value.target_port
        node_port    = port.value.node_port
        app_protocol = port.value.app_protocol
      }
    }

    dynamic "session_affinity_config" {
      for_each = each.value.session_affinity_client_ip_timeout_seconds != null ? [each.value.session_affinity_client_ip_timeout_seconds] : []
      content {
        client_ip {
          timeout_seconds = session_affinity_config.value
        }
      }
    }
  }

  # Defaults to waiting only for LoadBalancer Services; override with wait_for_load_balancer.
  wait_for_load_balancer = each.value.wait_for_load_balancer != null ? each.value.wait_for_load_balancer : each.value.type == "LoadBalancer"

  lifecycle {
    ignore_changes = [
      # The GKE NEG controller writes this annotation back; ignore to avoid perpetual diffs.
      metadata[0].annotations["cloud.google.com/neg-status"]
    ]
  }
}
