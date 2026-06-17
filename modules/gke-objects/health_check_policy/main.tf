resource "kubernetes_manifest" "this" {
  for_each = { for hc in var.health_check_policies : hc.name => hc }

  manifest = {
    "apiVersion" = "networking.gke.io/v1"
    "kind"       = "HealthCheckPolicy"
    "metadata" = {
      "name"        = each.value.name
      "namespace"   = each.value.namespace
      "labels"      = each.value.labels
      "annotations" = each.value.annotations
    }
    "spec" = {
      "default" = merge(
        each.value.check_interval_sec != null ? { "checkIntervalSec" = each.value.check_interval_sec } : {},
        each.value.timeout_sec != null ? { "timeoutSec" = each.value.timeout_sec } : {},
        each.value.healthy_threshold != null ? { "healthyThreshold" = each.value.healthy_threshold } : {},
        each.value.unhealthy_threshold != null ? { "unhealthyThreshold" = each.value.unhealthy_threshold } : {},
        each.value.log_config != null ? {
          "logConfig" = {
            "enabled" = each.value.log_config.enabled
          }
        } : {},
        {
          "config" = merge(
            {
              "type" = each.value.config.type
            },
            each.value.config.http_health_check != null ? {
              "httpHealthCheck" = merge(
                each.value.config.http_health_check.port != null ? { "port" = each.value.config.http_health_check.port } : {},
                each.value.config.http_health_check.port_name != null ? { "portName" = each.value.config.http_health_check.port_name } : {},
                each.value.config.http_health_check.port_specification != null ? { "portSpecification" = each.value.config.http_health_check.port_specification } : {},
                each.value.config.http_health_check.request_path != null ? { "requestPath" = each.value.config.http_health_check.request_path } : {},
                each.value.config.http_health_check.host != null ? { "host" = each.value.config.http_health_check.host } : {},
                each.value.config.http_health_check.response != null ? { "response" = each.value.config.http_health_check.response } : {},
                each.value.config.http_health_check.proxy_header != null ? { "proxyHeader" = each.value.config.http_health_check.proxy_header } : {},
              )
            } : {},
            each.value.config.https_health_check != null ? {
              "httpsHealthCheck" = merge(
                each.value.config.https_health_check.port != null ? { "port" = each.value.config.https_health_check.port } : {},
                each.value.config.https_health_check.port_name != null ? { "portName" = each.value.config.https_health_check.port_name } : {},
                each.value.config.https_health_check.port_specification != null ? { "portSpecification" = each.value.config.https_health_check.port_specification } : {},
                each.value.config.https_health_check.request_path != null ? { "requestPath" = each.value.config.https_health_check.request_path } : {},
                each.value.config.https_health_check.host != null ? { "host" = each.value.config.https_health_check.host } : {},
                each.value.config.https_health_check.response != null ? { "response" = each.value.config.https_health_check.response } : {},
                each.value.config.https_health_check.proxy_header != null ? { "proxyHeader" = each.value.config.https_health_check.proxy_header } : {},
              )
            } : {},
            each.value.config.http2_health_check != null ? {
              "http2HealthCheck" = merge(
                each.value.config.http2_health_check.port != null ? { "port" = each.value.config.http2_health_check.port } : {},
                each.value.config.http2_health_check.port_name != null ? { "portName" = each.value.config.http2_health_check.port_name } : {},
                each.value.config.http2_health_check.port_specification != null ? { "portSpecification" = each.value.config.http2_health_check.port_specification } : {},
                each.value.config.http2_health_check.request_path != null ? { "requestPath" = each.value.config.http2_health_check.request_path } : {},
                each.value.config.http2_health_check.host != null ? { "host" = each.value.config.http2_health_check.host } : {},
                each.value.config.http2_health_check.response != null ? { "response" = each.value.config.http2_health_check.response } : {},
                each.value.config.http2_health_check.proxy_header != null ? { "proxyHeader" = each.value.config.http2_health_check.proxy_header } : {},
              )
            } : {},
            each.value.config.grpc_health_check != null ? {
              "grpcHealthCheck" = merge(
                each.value.config.grpc_health_check.port != null ? { "port" = each.value.config.grpc_health_check.port } : {},
                each.value.config.grpc_health_check.port_name != null ? { "portName" = each.value.config.grpc_health_check.port_name } : {},
                each.value.config.grpc_health_check.port_specification != null ? { "portSpecification" = each.value.config.grpc_health_check.port_specification } : {},
                each.value.config.grpc_health_check.grpc_service_name != null ? { "grpcServiceName" = each.value.config.grpc_health_check.grpc_service_name } : {},
              )
            } : {},
            each.value.config.tcp_health_check != null ? {
              "tcpHealthCheck" = merge(
                each.value.config.tcp_health_check.port != null ? { "port" = each.value.config.tcp_health_check.port } : {},
                each.value.config.tcp_health_check.port_name != null ? { "portName" = each.value.config.tcp_health_check.port_name } : {},
                each.value.config.tcp_health_check.port_specification != null ? { "portSpecification" = each.value.config.tcp_health_check.port_specification } : {},
                each.value.config.tcp_health_check.request != null ? { "request" = each.value.config.tcp_health_check.request } : {},
                each.value.config.tcp_health_check.response != null ? { "response" = each.value.config.tcp_health_check.response } : {},
                each.value.config.tcp_health_check.proxy_header != null ? { "proxyHeader" = each.value.config.tcp_health_check.proxy_header } : {},
              )
            } : {},
          )
        },
      )
      "targetRef" = merge(
        {
          "group" = each.value.target_ref.group
          "kind"  = each.value.target_ref.kind
          "name"  = each.value.target_ref.name
        },
        each.value.target_ref.namespace != null ? { "namespace" = each.value.target_ref.namespace } : {},
      )
    }
  }

  field_manager {
    force_conflicts = true
  }
}
