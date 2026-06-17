resource "kubernetes_manifest" "this" {
  for_each = { for wg in var.workload_groups : wg.name => wg }

  manifest = {
    "apiVersion" = "networking.istio.io/v1beta1"
    "kind"       = "WorkloadGroup"
    "metadata" = merge({
      "name"      = each.value.name
      "namespace" = each.value.namespace
      },
      each.value.labels != null ? { labels = each.value.labels } : {},
      each.value.annotations != null ? { annotations = each.value.annotations } : {},
    )
    "spec" = merge(
      {
        "template" = merge(
          each.value.template.address != null ? { "address" = each.value.template.address } : {},
          length(each.value.template.ports) > 0 ? { "ports" = each.value.template.ports } : {},
          each.value.template.service_account != null ? { "serviceAccount" = each.value.template.service_account } : {},
          each.value.template.network != null ? { "network" = each.value.template.network } : {},
          each.value.template.locality != null ? { "locality" = each.value.template.locality } : {},
          each.value.template.weight != null ? { "weight" = each.value.template.weight } : {},
          length(each.value.template.labels) > 0 ? { "labels" = each.value.template.labels } : {},
        )
      },
      each.value.template_metadata != null ? {
        "metadata" = merge(
          length(each.value.template_metadata.labels) > 0 ? { "labels" = each.value.template_metadata.labels } : {},
          length(each.value.template_metadata.annotations) > 0 ? { "annotations" = each.value.template_metadata.annotations } : {},
        )
      } : {},
      each.value.probe != null ? {
        "probe" = merge(
          each.value.probe.initial_delay_seconds != null ? { "initialDelaySeconds" = each.value.probe.initial_delay_seconds } : {},
          each.value.probe.timeout_seconds != null ? { "timeoutSeconds" = each.value.probe.timeout_seconds } : {},
          each.value.probe.period_seconds != null ? { "periodSeconds" = each.value.probe.period_seconds } : {},
          each.value.probe.success_threshold != null ? { "successThreshold" = each.value.probe.success_threshold } : {},
          each.value.probe.failure_threshold != null ? { "failureThreshold" = each.value.probe.failure_threshold } : {},
          each.value.probe.http_get != null ? {
            "httpGet" = merge(
              {
                "port" = each.value.probe.http_get.port
              },
              each.value.probe.http_get.path != null ? { "path" = each.value.probe.http_get.path } : {},
              each.value.probe.http_get.host != null ? { "host" = each.value.probe.http_get.host } : {},
              each.value.probe.http_get.scheme != null ? { "scheme" = each.value.probe.http_get.scheme } : {},
              length(each.value.probe.http_get.http_headers) > 0 ? {
                "httpHeaders" = [
                  for h in each.value.probe.http_get.http_headers : {
                    "name"  = h.name
                    "value" = h.value
                  }
                ]
              } : {},
            )
          } : {},
          each.value.probe.tcp_socket != null ? {
            "tcpSocket" = merge(
              {
                "port" = each.value.probe.tcp_socket.port
              },
              each.value.probe.tcp_socket.host != null ? { "host" = each.value.probe.tcp_socket.host } : {},
            )
          } : {},
          each.value.probe.exec != null ? {
            "exec" = { "command" = each.value.probe.exec.command }
          } : {},
          each.value.probe.grpc != null ? {
            "grpc" = merge(
              {
                "port" = each.value.probe.grpc.port
              },
              each.value.probe.grpc.service != null ? { "service" = each.value.probe.grpc.service } : {},
            )
          } : {},
        )
      } : {},
    )
  }

  field_manager {
    force_conflicts = true
  }
}
