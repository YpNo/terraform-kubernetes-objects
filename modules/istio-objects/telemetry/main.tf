resource "kubernetes_manifest" "this" {
  for_each = { for tm in var.telemetries : tm.name => tm }

  manifest = {
    "apiVersion" = "telemetry.istio.io/v1alpha1"
    "kind"       = "Telemetry"
    "metadata" = merge(
      {
        "name" = each.value.name
        (each.value.namespace != null ? "namespace" : null) : each.value.namespace,
      },
      each.value.labels != null ? { labels = each.value.labels } : {},
      each.value.annotations != null ? { annotations = each.value.annotations } : {},
    )
    "spec" = merge(
      each.value.selector != null ? { "selector" = { "matchLabels" = each.value.selector } } : {},

      # Metrics Configuration
      length(each.value.metrics) > 0 ? {
        "metrics" = [
          for metric in each.value.metrics : merge(
            length(metric.providers) > 0 ? { "providers" = [for p in metric.providers : { "name" = p }] } : {},
            length(metric.overrides) > 0 ? {
              "overrides" = [
                for ov in metric.overrides : merge(
                  { "name" = ov.name },
                  length(ov.tags) > 0 ? { "tags" = ov.tags } : {},
                )
              ]
            } : {},
            metric.reporting_duration != null ? { "reportingDuration" = metric.reporting_duration } : {},
            metric.empty_duration != null ? { "emptyDuration" = metric.empty_duration } : {},
            metric.disabled != null ? { "disabled" = metric.disabled } : {},
          )
        ]
      } : {},

      # Access Logging Configuration
      length(each.value.access_logging) > 0 ? {
        "accessLogging" = [
          for al in each.value.access_logging : merge(
            length(al.providers) > 0 ? { "providers" = [for p in al.providers : { "name" = p }] } : {},
            al.disabled != null ? { "disabled" = al.disabled } : {},
            al.custom_format != null ? { "customFormat" = jsondecode(al.custom_format) } : {}, # Expects JSON string for custom_format
            al.filter != null ? { "filter" = { "expression" = al.filter.expression } } : {},
            al.encoding != null ? { "encoding" = al.encoding } : {},
          )
        ]
      } : {},

      # Tracing Configuration
      length(each.value.tracing) > 0 ? {
        "tracing" = [
          for trace in each.value.tracing : merge(
            length(trace.providers) > 0 ? { "providers" = [for p in trace.providers : { "name" = p }] } : {},
            trace.sampling != null ? { "sampling" = { "percent" = trace.sampling.percent } } : {},
            length(trace.custom_tags) > 0 ? {
              "customTags" = {
                for key, tag in trace.custom_tags : key => merge(
                  tag.literal != null ? { "literal" = { "value" = tag.literal.value } } : {},
                  tag.header != null ? {
                    "header" = merge(
                      { "name" = tag.header.name },
                      tag.header.omit_if_not_present != null ? { "omitIfNotFound" = tag.header.omit_if_not_present } : {},
                    )
                  } : {},
                  tag.environment != null ? {
                    "environment" = merge(
                      { "name" = tag.environment.name },
                      tag.environment.omit_if_not_present != null ? { "omitIfNotFound" = tag.environment.omit_if_not_present } : {},
                    )
                  } : {},
                )
              }
            } : {},
            trace.match != null ? {
              "match" = merge(
                trace.match.mode != null ? { "mode" = trace.match.mode } : {},
                trace.match.port != null ? { "port" = trace.match.port } : {},
                length(trace.match.headers) > 0 ? { "headers" = trace.match.headers } : {},
              )
            } : {},
            trace.disabled != null ? { "disabled" = trace.disabled } : {},
          )
        ]
      } : {}
    )
  }

  field_manager {
    force_conflicts = true
  }
}
