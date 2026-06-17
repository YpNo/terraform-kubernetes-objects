resource "kubernetes_manifest" "this" {
  for_each = { for vs in var.virtual_services : vs.name => vs }

  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "VirtualService"
    metadata = merge(
      {
        name      = each.value.name
        namespace = each.value.namespace
      },
      each.value.labels != null ? { labels = each.value.labels } : {},
      each.value.annotations != null ? { annotations = each.value.annotations } : {},
    )
    "spec" = merge(
      {
        "hosts"    = each.value.hosts
        "gateways" = each.value.gateways
      },
      # HTTP Rules
      length(each.value.http) > 0 ? {
        "http" = [
          for http_rule in each.value.http : merge(
            # Match conditions
            length(http_rule.match) > 0 ? {
              "match" = [
                for match_item in http_rule.match : merge(
                  match_item.uri != null ? { "uri" = match_item.uri } : {},
                  length(match_item.headers) > 0 ? { "headers" = match_item.headers } : {},
                  length(match_item.query_params) > 0 ? { "queryParams" = match_item.query_params } : {},
                  match_item.method != null ? { "method" = match_item.method } : {},
                  length(match_item.source_labels) > 0 ? { "sourceLabels" = match_item.source_labels } : {},
                  length(match_item.gateways) > 0 ? { "gateways" = match_item.gateways } : {},
                  match_item.port != null ? { "port" = match_item.port } : {},
                )
              ]
            } : {},
            # Route Destinations
            length(http_rule.route) > 0 ? {
              "route" = [
                for route_item in http_rule.route : merge(
                  {
                    "destination" = merge(
                      { "host" = route_item.destination.host },
                      route_item.destination.subset != null ? { "subset" = route_item.destination.subset } : {},
                      route_item.destination.port != null ? { "port" = { "number" = route_item.destination.port } } : {},
                    )
                  },
                  route_item.weight != null ? { "weight" = route_item.weight } : {},
                )
              ]
            } : {},
            # Optional Actions (mutually exclusive with route for simple redirect/rewrite)
            http_rule.redirect != null ? {
              "redirect" = merge(
                http_rule.redirect.uri != null ? { "uri" = http_rule.redirect.uri } : {},
                http_rule.redirect.authority != null ? { "authority" = http_rule.redirect.authority } : {},
                http_rule.redirect.redirect_code != null ? { "redirectCode" = http_rule.redirect.redirect_code } : {},
              )
            } : {},
            http_rule.delegate != null ? {
              "delegate" = merge(
                { "name" = http_rule.delegate.name },
                http_rule.delegate.namespace != null ? { "namespace" = http_rule.delegate.namespace } : {},
              )
            } : {},
            http_rule.rewrite != null ? {
              "rewrite" = merge(
                http_rule.rewrite.uri != null ? { "uri" = http_rule.rewrite.uri } : {},
                http_rule.rewrite.authority != null ? { "authority" = http_rule.rewrite.authority } : {},
                http_rule.rewrite.uri_regex_rewrite != null ? {
                  "uriRegexRewrite" = { # Corrected field name for manifest
                    "match"   = http_rule.rewrite.uri_regex_rewrite.match
                    "rewrite" = http_rule.rewrite.uri_regex_rewrite.rewrite
                  }
                } : {},
              )
            } : {},
            http_rule.timeout != null ? { "timeout" = http_rule.timeout } : {},
            http_rule.retries != null ? {
              "retries" = merge(
                { "attempts" = http_rule.retries.attempts },
                http_rule.retries.per_try_timeout != null ? { "perTryTimeout" = http_rule.retries.per_try_timeout } : {},
                http_rule.retries.retry_on != null ? { "retryOn" = http_rule.retries.retry_on } : {},
              )
            } : {},
            http_rule.fault != null ? {
              "fault" = merge(
                http_rule.fault.delay != null ? {
                  "delay" = merge(
                    { "fixedDelay" = http_rule.fault.delay.fixed_delay },
                    { "percentage" = { "value" = http_rule.fault.delay.percentage } },
                  )
                } : {},
                http_rule.fault.abort != null ? {
                  "abort" = merge(
                    { "httpStatus" = http_rule.fault.abort.http_status },
                    { "percentage" = { "value" = http_rule.fault.abort.percentage } },
                  )
                } : {},
              )
            } : {},
            http_rule.mirror != null ? {
              "mirror" = merge(
                { "host" = http_rule.mirror.host },
                http_rule.mirror.subset != null ? { "subset" = http_rule.mirror.subset } : {},
                http_rule.mirror.port != null ? { "port" = { "number" = http_rule.mirror.port } } : {},
              )
            } : {},
            http_rule.mirror_percentage != null ? { "mirrorPercentage" = { "value" = http_rule.mirror_percentage } } : {},
            http_rule.cors_policy != null ? {
              "corsPolicy" = merge(
                length(http_rule.cors_policy.allow_origins) > 0 ? {
                  "allowOrigins" = [
                    for ao in http_rule.cors_policy.allow_origins : merge(
                      ao.exact != null ? { "exact" = ao.exact } : {},
                      ao.prefix != null ? { "prefix" = ao.prefix } : {},
                      ao.regex != null ? { "regex" = ao.regex } : {},
                    )
                  ]
                } : {},
                length(http_rule.cors_policy.allow_methods) > 0 ? { "allowMethods" = http_rule.cors_policy.allow_methods } : {},
                length(http_rule.cors_policy.allow_headers) > 0 ? { "allowHeaders" = http_rule.cors_policy.allow_headers } : {},
                length(http_rule.cors_policy.expose_headers) > 0 ? { "exposeHeaders" = http_rule.cors_policy.expose_headers } : {},
                http_rule.cors_policy.max_age != null ? { "maxAge" = http_rule.cors_policy.max_age } : {},
                http_rule.cors_policy.allow_credentials != null ? { "allowCredentials" = http_rule.cors_policy.allow_credentials } : {},
              )
            } : {},
            http_rule.headers != null ? {
              "headers" = merge(
                http_rule.headers.request != null ? {
                  "request" = merge(
                    length(http_rule.headers.request.set) > 0 ? { "set" = http_rule.headers.request.set } : {},
                    length(http_rule.headers.request.add) > 0 ? { "add" = http_rule.headers.request.add } : {},
                    length(http_rule.headers.request.remove) > 0 ? { "remove" = http_rule.headers.request.remove } : {},
                  )
                } : {},
                http_rule.headers.response != null ? {
                  "response" = merge(
                    length(http_rule.headers.response.set) > 0 ? { "set" = http_rule.headers.response.set } : {},
                    length(http_rule.headers.response.add) > 0 ? { "add" = http_rule.headers.response.add } : {},
                    length(http_rule.headers.response.remove) > 0 ? { "remove" = http_rule.headers.response.remove } : {},
                  )
                } : {},
              )
            } : {},
            http_rule.direct_response != null ? {
              "directResponse" = merge(
                { "status" = http_rule.direct_response.status },
                http_rule.direct_response.body != null ? {
                  "body" = merge(
                    http_rule.direct_response.body.string != null ? { "string" = http_rule.direct_response.body.string } : {},
                    http_rule.direct_response.body.bytes != null ? { "bytes" = http_rule.direct_response.body.bytes } : {},
                  )
                } : {},
              )
            } : {}
          )
        ]
      } : {},

      # TLS Rules
      length(each.value.tls) > 0 ? {
        "tls" = [
          for tls_rule in each.value.tls : merge(
            length(tls_rule.match) > 0 ? {
              "match" = [
                for match_item in tls_rule.match : merge(
                  length(match_item.sni_hosts) > 0 ? { "sniHosts" = match_item.sni_hosts } : {},
                  match_item.port != null ? { "port" = match_item.port } : {},
                )
              ]
            } : {},
            length(tls_rule.route) > 0 ? {
              "route" = [
                for route_item in tls_rule.route : merge(
                  {
                    "destination" = merge(
                      { "host" = route_item.destination.host },
                      route_item.destination.subset != null ? { "subset" = route_item.destination.subset } : {},
                      route_item.destination.port != null ? { "port" = { "number" = route_item.destination.port } } : {},
                    )
                  },
                  route_item.weight != null ? { "weight" = route_item.weight } : {},
                )
              ]
            } : {},
          )
        ]
      } : {},

      # TCP Rules
      length(each.value.tcp) > 0 ? {
        "tcp" = [
          for tcp_rule in each.value.tcp : merge(
            length(tcp_rule.match) > 0 ? {
              "match" = [
                for match_item in tcp_rule.match : merge(
                  match_item.port != null ? { "port" = match_item.port } : {},
                  length(match_item.sni_hosts) > 0 ? { "sniHosts" = match_item.sni_hosts } : {},
                  length(match_item.source_labels) > 0 ? { "sourceLabels" = match_item.source_labels } : {},
                )
              ]
            } : {},
            length(tcp_rule.route) > 0 ? {
              "route" = [
                for route_item in tcp_rule.route : merge(
                  {
                    "destination" = merge(
                      { "host" = route_item.destination.host },
                      route_item.destination.subset != null ? { "subset" = route_item.destination.subset } : {},
                      route_item.destination.port != null ? { "port" = { "number" = route_item.destination.port } } : {},
                    )
                  },
                  route_item.weight != null ? { "weight" = route_item.weight } : {},
                )
              ]
            } : {},
          )
        ]
      } : {},
    )
  }

  field_manager {
    force_conflicts = true
  }
}
