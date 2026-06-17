resource "kubernetes_api_service_v1" "this" {
  for_each = { for a in var.api_services : a.name => a }

  metadata {
    name        = each.value.name
    labels      = each.value.labels
    annotations = each.value.annotations
  }

  spec {
    group                    = each.value.spec.group
    group_priority_minimum   = each.value.spec.group_priority_minimum
    version                  = each.value.spec.version
    version_priority         = each.value.spec.version_priority
    ca_bundle                = each.value.spec.ca_bundle
    insecure_skip_tls_verify = each.value.spec.insecure_skip_tls_verify

    dynamic "service" {
      for_each = each.value.spec.service != null ? [each.value.spec.service] : []

      content {
        name      = service.value.name
        namespace = service.value.namespace
        port      = service.value.port
      }
    }
  }
}
