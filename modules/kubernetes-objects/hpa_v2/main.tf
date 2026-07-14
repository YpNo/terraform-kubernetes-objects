resource "kubernetes_horizontal_pod_autoscaler_v2" "this" {
  for_each = { for h in var.hpas : h.name => h }

  metadata {
    name      = each.value.name
    namespace = each.value.namespace
  }

  spec {
    scale_target_ref {
      kind        = each.value.target_kind
      api_version = each.value.target_api_version
      name        = each.value.target_name
    }
    max_replicas = each.value.max_replicas
    min_replicas = each.value.min_replicas

    target_cpu_utilization_percentage = each.value.target_cpu_utilization_percentage

    dynamic "metric" {
      for_each = each.value.metrics

      content {
        type = metric.value.type
        dynamic "resource" {
          for_each = metric.value.resources

          content {
            name = resource.value.name
            target {
              type                = resource.value.target.type
              average_value       = resource.value.target.average_value
              average_utilization = resource.value.target.average_utilization
              value               = resource.value.target.value
            }
          }
        }

        dynamic "external" {
          for_each = metric.value.externals

          content {
            metric {
              name = external.value.metric.name
              selector {
                match_labels = external.value.metric.match_labels
              }
            }
            target {
              type                = external.value.target.type
              average_utilization = external.value.target.average_utilization
              average_value       = external.value.target.average_value
              value               = external.value.target.value
            }
          }
        }
      }
    }
  }
}