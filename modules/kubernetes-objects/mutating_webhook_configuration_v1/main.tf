resource "kubernetes_mutating_webhook_configuration_v1" "this" {
  for_each = { for c in var.mutating_webhook_configurations : c.name => c }

  metadata {
    name        = each.value.name
    labels      = each.value.labels
    annotations = each.value.annotations
  }

  dynamic "webhook" {
    for_each = each.value.webhooks

    content {
      name                      = webhook.value.name
      admission_review_versions = webhook.value.admission_review_versions
      failure_policy            = webhook.value.failure_policy
      match_policy              = webhook.value.match_policy
      side_effects              = webhook.value.side_effects
      timeout_seconds           = webhook.value.timeout_seconds
      reinvocation_policy       = webhook.value.reinvocation_policy

      client_config {
        ca_bundle = webhook.value.client_config.ca_bundle
        url       = webhook.value.client_config.url

        dynamic "service" {
          for_each = webhook.value.client_config.service != null ? [webhook.value.client_config.service] : []

          content {
            name      = service.value.name
            namespace = service.value.namespace
            path      = service.value.path
            port      = service.value.port
          }
        }
      }

      dynamic "rule" {
        for_each = webhook.value.rules

        content {
          api_groups   = rule.value.api_groups
          api_versions = rule.value.api_versions
          operations   = rule.value.operations
          resources    = rule.value.resources
          scope        = rule.value.scope
        }
      }

      dynamic "namespace_selector" {
        for_each = webhook.value.namespace_selector != null ? [webhook.value.namespace_selector] : []

        content {
          match_labels = namespace_selector.value.match_labels

          dynamic "match_expressions" {
            for_each = namespace_selector.value.match_expressions

            content {
              key      = match_expressions.value.key
              operator = match_expressions.value.operator
              values   = match_expressions.value.values
            }
          }
        }
      }

      dynamic "object_selector" {
        for_each = webhook.value.object_selector != null ? [webhook.value.object_selector] : []

        content {
          match_labels = object_selector.value.match_labels

          dynamic "match_expressions" {
            for_each = object_selector.value.match_expressions

            content {
              key      = match_expressions.value.key
              operator = match_expressions.value.operator
              values   = match_expressions.value.values
            }
          }
        }
      }
    }
  }
}
