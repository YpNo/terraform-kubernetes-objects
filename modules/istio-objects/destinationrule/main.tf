resource "kubernetes_manifest" "this" {
  for_each = { for dr in var.destination_rules : dr.name => dr }

  manifest = {
    "apiVersion" = "networking.istio.io/v1beta1"
    "kind"       = "DestinationRule"
    "metadata" = merge(
      {
        "name"      = each.value.name
        "namespace" = each.value.namespace
      },
      each.value.labels != null ? { "labels" = each.value.labels } : {},
      each.value.annotations != null ? { "annotations" = each.value.annotations } : {},
    )
    "spec" = merge(
      {
        "host" = each.value.host
      },
      each.value.traffic_policy != null ? {
        "trafficPolicy" = merge(
          each.value.traffic_policy.load_balancer != null ? {
            "loadBalancer" = merge(
              each.value.traffic_policy.load_balancer.simple != null ? { "simple" = each.value.traffic_policy.load_balancer.simple } : {},
              each.value.traffic_policy.load_balancer.consistent_hash != null ? {
                "consistentHash" = merge(
                  each.value.traffic_policy.load_balancer.consistent_hash.http_header != null ? { "httpHeader" = each.value.traffic_policy.load_balancer.consistent_hash.http_header } : {},
                  each.value.traffic_policy.load_balancer.consistent_hash.http_cookie != null ? {
                    "httpCookie" = merge(
                      { "name" = each.value.traffic_policy.load_balancer.consistent_hash.http_cookie.name },
                      { "path" = each.value.traffic_policy.load_balancer.consistent_hash.http_cookie.path },
                      { "ttl" = each.value.traffic_policy.load_balancer.consistent_hash.http_cookie.ttl },
                    )
                  } : {},
                  each.value.traffic_policy.load_balancer.consistent_hash.use_source_ip != null ? { "useSourceIp" = each.value.traffic_policy.load_balancer.consistent_hash.use_source_ip } : {},
                  each.value.traffic_policy.load_balancer.consistent_hash.http_query_parameter != null ? { "httpQueryParameter" = each.value.traffic_policy.load_balancer.consistent_hash.http_query_parameter } : {},
                )
              } : {},
            )
          } : {},
          each.value.traffic_policy.connection_pool != null ? {
            "connectionPool" = merge(
              each.value.traffic_policy.connection_pool.http != null ? {
                "http" = merge(
                  each.value.traffic_policy.connection_pool.http.http1_max_pending_requests != null ? { "http1MaxPendingRequests" = each.value.traffic_policy.connection_pool.http.http1_max_pending_requests } : {},
                  each.value.traffic_policy.connection_pool.http.http2_max_requests != null ? { "http2MaxRequests" = each.value.traffic_policy.connection_pool.http.http2_max_requests } : {},
                  each.value.traffic_policy.connection_pool.http.max_requests_per_connection != null ? { "maxRequestsPerConnection" = each.value.traffic_policy.connection_pool.http.max_requests_per_connection } : {},
                  each.value.traffic_policy.connection_pool.http.max_retries != null ? { "maxRetries" = each.value.traffic_policy.connection_pool.http.max_retries } : {},
                  each.value.traffic_policy.connection_pool.http.idle_timeout != null ? { "idleTimeout" = each.value.traffic_policy.connection_pool.http.idle_timeout } : {},
                  each.value.traffic_policy.connection_pool.http.h2_upgrade_policy != null ? { "h2UpgradePolicy" = each.value.traffic_policy.connection_pool.http.h2_upgrade_policy } : {},
                )
              } : {},
              each.value.traffic_policy.connection_pool.tcp != null ? {
                "tcp" = merge(
                  each.value.traffic_policy.connection_pool.tcp.max_connections != null ? { "maxConnections" = each.value.traffic_policy.connection_pool.tcp.max_connections } : {},
                  each.value.traffic_policy.connection_pool.tcp.connect_timeout != null ? { "connectTimeout" = each.value.traffic_policy.connection_pool.tcp.connect_timeout } : {},
                  each.value.traffic_policy.connection_pool.tcp.tcp_keepalive != null ? {
                    "tcpKeepalive" = merge(
                      each.value.traffic_policy.connection_pool.tcp.tcp_keepalive.probes != null ? { "probes" = each.value.traffic_policy.connection_pool.tcp.tcp_keepalive.probes } : {},
                      each.value.traffic_policy.connection_pool.tcp.tcp_keepalive.time != null ? { "time" = each.value.traffic_policy.connection_pool.tcp.tcp_keepalive.time } : {},
                      each.value.traffic_policy.connection_pool.tcp.tcp_keepalive.interval != null ? { "interval" = each.value.traffic_policy.connection_pool.tcp.tcp_keepalive.interval } : {},
                    )
                  } : {},
                )
              } : {},
            )
          } : {},
          each.value.traffic_policy.outlier_detection != null ? {
            "outlierDetection" = merge(
              each.value.traffic_policy.outlier_detection.consecutive_5xx_errors != null ? { "consecutive5xxErrors" = each.value.traffic_policy.outlier_detection.consecutive_5xx_errors } : {},
              each.value.traffic_policy.outlier_detection.consecutive_gateway_errors != null ? { "consecutiveGatewayErrors" = each.value.traffic_policy.outlier_detection.consecutive_gateway_errors } : {},
              each.value.traffic_policy.outlier_detection.interval != null ? { "interval" = each.value.traffic_policy.outlier_detection.interval } : {},
              each.value.traffic_policy.outlier_detection.base_ejection_time != null ? { "baseEjectionTime" = each.value.traffic_policy.outlier_detection.base_ejection_time } : {},
              each.value.traffic_policy.outlier_detection.max_ejection_percent != null ? { "maxEjectionPercent" = each.value.traffic_policy.outlier_detection.max_ejection_percent } : {},
              each.value.traffic_policy.outlier_detection.consecutive_errors != null ? { "consecutiveErrors" = each.value.traffic_policy.outlier_detection.consecutive_errors } : {},
            )
          } : {},
          each.value.traffic_policy.tls != null ? {
            "tls" = merge(
              { "mode" = each.value.traffic_policy.tls.mode },
              each.value.traffic_policy.tls.credential_name != null ? { "credentialName" = each.value.traffic_policy.tls.credential_name } : {},
              each.value.traffic_policy.tls.client_certificate != null ? { "clientCertificate" = each.value.traffic_policy.tls.client_certificate } : {},
              each.value.traffic_policy.tls.private_key != null ? { "privateKey" = each.value.traffic_policy.tls.private_key } : {},
              each.value.traffic_policy.tls.ca_certificates != null ? { "caCertificates" = each.value.traffic_policy.tls.ca_certificates } : {},
              length(each.value.traffic_policy.tls.subject_alt_names) > 0 ? { "subjectAltNames" = each.value.traffic_policy.tls.subject_alt_names } : {},
              each.value.traffic_policy.tls.min_protocol_version != null ? { "minProtocolVersion" = each.value.traffic_policy.tls.min_protocol_version } : {},
              each.value.traffic_policy.tls.max_protocol_version != null ? { "maxProtocolVersion" = each.value.traffic_policy.tls.max_protocol_version } : {},
              length(each.value.traffic_policy.tls.cipher_suites) > 0 ? { "cipherSuites" = each.value.traffic_policy.tls.cipher_suites } : {},
              each.value.traffic_policy.tls.sni != null ? { "sni" = each.value.traffic_policy.tls.sni } : {},
            )
          } : {},
          each.value.traffic_policy.port_level_settings != null ? {
            "portLevelSettings" = [
              for pls in each.value.traffic_policy.port_level_settings : merge(
                { "port" = { "number" = pls.port_number } },
                (pls.load_balancer != null ? { "loadBalancer" = merge(
                  pls.load_balancer.simple != null ? { "simple" = pls.load_balancer.simple } : {},
                  pls.load_balancer.consistent_hash != null ? {
                    "consistentHash" = merge(
                      pls.load_balancer.consistent_hash.http_header != null ? { "httpHeader" = pls.load_balancer.consistent_hash.http_header } : {},
                      pls.load_balancer.consistent_hash.http_cookie != null ? {
                        "httpCookie" = merge(
                          { "name" = pls.load_balancer.consistent_hash.http_cookie.name },
                          { "path" = pls.load_balancer.consistent_hash.http_cookie.path },
                          { "ttl" = pls.load_balancer.consistent_hash.http_cookie.ttl },
                        )
                      } : {},
                      pls.load_balancer.consistent_hash.use_source_ip != null ? { "useSourceIp" = pls.load_balancer.consistent_hash.use_source_ip } : {},
                      pls.load_balancer.consistent_hash.http_query_parameter != null ? { "httpQueryParameter" = pls.load_balancer.consistent_hash.http_query_parameter } : {},
                    )
                  } : {},
                ) } : {}),
                (pls.connection_pool != null ? { "connectionPool" = merge(
                  pls.connection_pool.http != null ? {
                    "http" = merge(
                      pls.connection_pool.http.http1_max_pending_requests != null ? { "http1MaxPendingRequests" = pls.connection_pool.http.http1_max_pending_requests } : {},
                      pls.connection_pool.http.http2_max_requests != null ? { "http2MaxRequests" = pls.connection_pool.http.http2_max_requests } : {},
                      pls.connection_pool.http.max_requests_per_connection != null ? { "maxRequestsPerConnection" = pls.connection_pool.http.max_requests_per_connection } : {},
                      pls.connection_pool.http.max_retries != null ? { "maxRetries" = pls.connection_pool.http.max_retries } : {},
                      pls.connection_pool.http.idle_timeout != null ? { "idleTimeout" = pls.connection_pool.http.idle_timeout } : {},
                      pls.connection_pool.http.h2_upgrade_policy != null ? { "h2UpgradePolicy" = pls.connection_pool.http.h2_upgrade_policy } : {},
                    )
                  } : {},
                  pls.connection_pool.tcp != null ? {
                    "tcp" = merge(
                      pls.connection_pool.tcp.max_connections != null ? { "maxConnections" = pls.connection_pool.tcp.max_connections } : {},
                      pls.connection_pool.tcp.connect_timeout != null ? { "connectTimeout" = pls.connection_pool.tcp.connect_timeout } : {},
                      pls.connection_pool.tcp.tcp_keepalive != null ? {
                        "tcpKeepalive" = merge(
                          pls.connection_pool.tcp.tcp_keepalive.probes != null ? { "probes" = pls.connection_pool.tcp.tcp_keepalive.probes } : {},
                          pls.connection_pool.tcp.tcp_keepalive.time != null ? { "time" = pls.connection_pool.tcp.tcp_keepalive.time } : {},
                          pls.connection_pool.tcp.tcp_keepalive.interval != null ? { "interval" = pls.connection_pool.tcp.tcp_keepalive.interval } : {},
                        )
                      } : {},
                    )
                  } : {},
                ) } : {}),
                (pls.outlier_detection != null ? { "outlierDetection" = merge(
                  pls.outlier_detection.consecutive_5xx_errors != null ? { "consecutive5xxErrors" = pls.outlier_detection.consecutive_5xx_errors } : {},
                  pls.outlier_detection.consecutive_gateway_errors != null ? { "consecutiveGatewayErrors" = pls.outlier_detection.consecutive_gateway_errors } : {},
                  pls.outlier_detection.interval != null ? { "interval" = pls.outlier_detection.interval } : {},
                  pls.outlier_detection.base_ejection_time != null ? { "baseEjectionTime" = pls.outlier_detection.base_ejection_time } : {},
                  pls.outlier_detection.max_ejection_percent != null ? { "maxEjectionPercent" = pls.outlier_detection.max_ejection_percent } : {},
                  pls.outlier_detection.consecutive_errors != null ? { "consecutiveErrors" = pls.outlier_detection.consecutive_errors } : {},
                ) } : {}),
                (pls.tls != null ? { "tls" = merge(
                  { "mode" = pls.tls.mode },
                  pls.tls.credential_name != null ? { "credentialName" = pls.tls.credential_name } : {},
                  pls.tls.client_certificate != null ? { "clientCertificate" = pls.tls.client_certificate } : {},
                  pls.tls.private_key != null ? { "privateKey" = pls.tls.private_key } : {},
                  pls.tls.ca_certificates != null ? { "caCertificates" = pls.tls.ca_certificates } : {},
                  length(pls.tls.subject_alt_names) > 0 ? { "subjectAltNames" = pls.tls.subject_alt_names } : {},
                  pls.tls.min_protocol_version != null ? { "minProtocolVersion" = pls.tls.min_protocol_version } : {},
                  pls.tls.max_protocol_version != null ? { "maxProtocolVersion" = pls.tls.max_protocol_version } : {},
                  length(pls.tls.cipher_suites) > 0 ? { "cipherSuites" = pls.tls.cipher_suites } : {},
                  pls.tls.sni != null ? { "sni" = pls.tls.sni } : {},
                ) } : {}),
              )
            ]
          } : {},
        )
      } : {},
      length(each.value.subsets) > 0 ? {
        "subsets" = [
          for subset in each.value.subsets : merge(
            {
              "name"   = subset.name
              "labels" = subset.labels
            },
            subset.traffic_policy != null ? {
              "trafficPolicy" = merge(
                subset.traffic_policy.load_balancer != null ? {
                  "loadBalancer" = merge(
                    subset.traffic_policy.load_balancer.simple != null ? { "simple" = subset.traffic_policy.load_balancer.simple } : {},
                    subset.traffic_policy.load_balancer.consistent_hash != null ? {
                      "consistentHash" = merge(
                        subset.traffic_policy.load_balancer.consistent_hash.http_header != null ? { "httpHeader" = subset.traffic_policy.load_balancer.consistent_hash.http_header } : {},
                        subset.traffic_policy.load_balancer.consistent_hash.http_cookie != null ? {
                          "httpCookie" = merge(
                            { "name" = subset.traffic_policy.load_balancer.consistent_hash.http_cookie.name },
                            { "path" = subset.traffic_policy.load_balancer.consistent_hash.http_cookie.path },
                            { "ttl" = subset.traffic_policy.load_balancer.consistent_hash.http_cookie.ttl },
                          )
                        } : {},
                        subset.traffic_policy.load_balancer.consistent_hash.use_source_ip != null ? { "useSourceIp" = subset.traffic_policy.load_balancer.consistent_hash.use_source_ip } : {},
                        subset.traffic_policy.load_balancer.consistent_hash.http_query_parameter != null ? { "httpQueryParameter" = subset.traffic_policy.load_balancer.consistent_hash.http_query_parameter } : {},
                      )
                    } : {},
                  )
                } : {},
                subset.traffic_policy.connection_pool != null ? {
                  "connectionPool" = merge(
                    subset.traffic_policy.connection_pool.http != null ? {
                      "http" = merge(
                        subset.traffic_policy.connection_pool.http.http1_max_pending_requests != null ? { "http1MaxPendingRequests" = subset.traffic_policy.connection_pool.http.http1_max_pending_requests } : {},
                        subset.traffic_policy.connection_pool.http.http2_max_requests != null ? { "http2MaxRequests" = subset.traffic_policy.connection_pool.http.http2_max_requests } : {},
                        subset.traffic_policy.connection_pool.http.max_requests_per_connection != null ? { "maxRequestsPerConnection" = subset.traffic_policy.connection_pool.http.max_requests_per_connection } : {},
                        subset.traffic_policy.connection_pool.http.max_retries != null ? { "maxRetries" = subset.traffic_policy.connection_pool.http.max_retries } : {},
                        subset.traffic_policy.connection_pool.http.idle_timeout != null ? { "idleTimeout" = subset.traffic_policy.connection_pool.http.idle_timeout } : {},
                        subset.traffic_policy.connection_pool.http.h2_upgrade_policy != null ? { "h2UpgradePolicy" = subset.traffic_policy.connection_pool.http.h2_upgrade_policy } : {},
                      )
                    } : {},
                    subset.traffic_policy.connection_pool.tcp != null ? {
                      "tcp" = merge(
                        subset.traffic_policy.connection_pool.tcp.max_connections != null ? { "maxConnections" = subset.traffic_policy.connection_pool.tcp.max_connections } : {},
                        subset.traffic_policy.connection_pool.tcp.connect_timeout != null ? { "connectTimeout" = subset.traffic_policy.connection_pool.tcp.connect_timeout } : {},
                        subset.traffic_policy.connection_pool.tcp.tcp_keepalive != null ? {
                          "tcpKeepalive" = merge(
                            subset.traffic_policy.connection_pool.tcp.tcp_keepalive.probes != null ? { "probes" = subset.traffic_policy.connection_pool.tcp.tcp_keepalive.probes } : {},
                            subset.traffic_policy.connection_pool.tcp.tcp_keepalive.time != null ? { "time" = subset.traffic_policy.connection_pool.tcp.tcp_keepalive.time } : {},
                            subset.traffic_policy.connection_pool.tcp.tcp_keepalive.interval != null ? { "interval" = subset.traffic_policy.connection_pool.tcp.tcp_keepalive.interval } : {},
                          )
                        } : {},
                      )
                    } : {},
                  )
                } : {},
                subset.traffic_policy.outlier_detection != null ? {
                  "outlierDetection" = merge(
                    subset.traffic_policy.outlier_detection.consecutive_5xx_errors != null ? { "consecutive5xxErrors" = subset.traffic_policy.outlier_detection.consecutive_5xx_errors } : {},
                    subset.traffic_policy.outlier_detection.consecutive_gateway_errors != null ? { "consecutiveGatewayErrors" = subset.traffic_policy.outlier_detection.consecutive_gateway_errors } : {},
                    subset.traffic_policy.outlier_detection.interval != null ? { "interval" = subset.traffic_policy.outlier_detection.interval } : {},
                    subset.traffic_policy.outlier_detection.base_ejection_time != null ? { "baseEjectionTime" = subset.traffic_policy.outlier_detection.base_ejection_time } : {},
                    subset.traffic_policy.outlier_detection.max_ejection_percent != null ? { "maxEjectionPercent" = subset.traffic_policy.outlier_detection.max_ejection_percent } : {},
                    subset.traffic_policy.outlier_detection.consecutive_errors != null ? { "consecutiveErrors" = subset.traffic_policy.outlier_detection.consecutive_errors } : {},
                  )
                } : {},
                subset.traffic_policy.tls != null ? {
                  "tls" = merge(
                    { "mode" = subset.traffic_policy.tls.mode },
                    subset.traffic_policy.tls.credential_name != null ? { "credentialName" = subset.traffic_policy.tls.credential_name } : {},
                    subset.traffic_policy.tls.client_certificate != null ? { "clientCertificate" = subset.traffic_policy.tls.client_certificate } : {},
                    subset.traffic_policy.tls.private_key != null ? { "privateKey" = subset.traffic_policy.tls.private_key } : {},
                    subset.traffic_policy.tls.ca_certificates != null ? { "caCertificates" = subset.traffic_policy.tls.ca_certificates } : {},
                    length(subset.traffic_policy.tls.subject_alt_names) > 0 ? { "subjectAltNames" = subset.traffic_policy.tls.subject_alt_names } : {},
                    subset.traffic_policy.tls.min_protocol_version != null ? { "minProtocolVersion" = subset.traffic_policy.tls.min_protocol_version } : {},
                    subset.traffic_policy.tls.max_protocol_version != null ? { "maxProtocolVersion" = subset.traffic_policy.tls.max_protocol_version } : {},
                    length(subset.traffic_policy.tls.cipher_suites) > 0 ? { "cipherSuites" = subset.traffic_policy.tls.cipher_suites } : {},
                    subset.traffic_policy.tls.sni != null ? { "sni" = subset.traffic_policy.tls.sni } : {},
                  )
                } : {},
                subset.traffic_policy.port_level_settings != null ? {
                  "portLevelSettings" = [
                    for pls in subset.traffic_policy.port_level_settings : merge(
                      { "port" = { "number" = pls.port_number } },
                      pls.load_balancer != null ? { "loadBalancer" = merge(
                        pls.load_balancer.simple != null ? { "simple" = pls.load_balancer.simple } : {},
                        pls.load_balancer.consistent_hash != null ? {
                          "consistentHash" = merge(
                            pls.load_balancer.consistent_hash.http_header != null ? { "httpHeader" = pls.load_balancer.consistent_hash.http_header } : {},
                            pls.load_balancer.consistent_hash.http_cookie != null ? {
                              "httpCookie" = merge(
                                { "name" = pls.load_balancer.consistent_hash.http_cookie.name },
                                { "path" = pls.load_balancer.consistent_hash.http_cookie.path },
                                { "ttl" = pls.load_balancer.consistent_hash.http_cookie.ttl },
                              )
                            } : {},
                            pls.load_balancer.consistent_hash.use_source_ip != null ? { "useSourceIp" = pls.load_balancer.consistent_hash.use_source_ip } : {},
                            pls.load_balancer.consistent_hash.http_query_parameter != null ? { "httpQueryParameter" = pls.load_balancer.consistent_hash.http_query_parameter } : {},
                          )
                        } : {},
                      ) } : {},
                      pls.connection_pool != null ? { "connectionPool" = merge(
                        pls.connection_pool.http != null ? {
                          "http" = merge(
                            pls.connection_pool.http.http1_max_pending_requests != null ? { "http1MaxPendingRequests" = pls.connection_pool.http.http1_max_pending_requests } : {},
                            pls.connection_pool.http.http2_max_requests != null ? { "http2MaxRequests" = pls.connection_pool.http.http2_max_requests } : {},
                            pls.connection_pool.http.max_requests_per_connection != null ? { "maxRequestsPerConnection" = pls.connection_pool.http.max_requests_per_connection } : {},
                            pls.connection_pool.http.max_retries != null ? { "maxRetries" = pls.connection_pool.http.max_retries } : {},
                            pls.connection_pool.http.idle_timeout != null ? { "idleTimeout" = pls.connection_pool.http.idle_timeout } : {},
                            pls.connection_pool.http.h2_upgrade_policy != null ? { "h2UpgradePolicy" = pls.connection_pool.http.h2_upgrade_policy } : {},
                          )
                        } : {},
                        pls.connection_pool.tcp != null ? {
                          "tcp" = merge(
                            pls.connection_pool.tcp.max_connections != null ? { "maxConnections" = pls.connection_pool.tcp.max_connections } : {},
                            pls.connection_pool.tcp.connect_timeout != null ? { "connectTimeout" = pls.connection_pool.tcp.connect_timeout } : {},
                            pls.connection_pool.tcp.tcp_keepalive != null ? {
                              "tcpKeepalive" = merge(
                                pls.connection_pool.tcp.tcp_keepalive.probes != null ? { "probes" = pls.connection_pool.tcp.tcp_keepalive.probes } : {},
                                pls.connection_pool.tcp.tcp_keepalive.time != null ? { "time" = pls.connection_pool.tcp.tcp_keepalive.time } : {},
                                pls.connection_pool.tcp.tcp_keepalive.interval != null ? { "interval" = pls.connection_pool.tcp.tcp_keepalive.interval } : {},
                              )
                            } : {},
                          )
                        } : {},
                      ) } : {},
                      # These elements need to be merged into the *same* merge call as the port and connection pool
                      pls.outlier_detection != null ? { "outlierDetection" = merge(
                        pls.outlier_detection.consecutive_5xx_errors != null ? { "consecutive5xxErrors" = pls.outlier_detection.consecutive_5xx_errors } : {},
                        pls.outlier_detection.consecutive_gateway_errors != null ? { "consecutiveGatewayErrors" = pls.outlier_detection.consecutive_gateway_errors } : {},
                        pls.outlier_detection.interval != null ? { "interval" = pls.outlier_detection.interval } : {},
                        pls.outlier_detection.base_ejection_time != null ? { "baseEjectionTime" = pls.outlier_detection.base_ejection_time } : {},
                        pls.outlier_detection.max_ejection_percent != null ? { "maxEjectionPercent" = pls.outlier_detection.max_ejection_percent } : {},
                        pls.outlier_detection.consecutive_errors != null ? { "consecutiveErrors" = pls.outlier_detection.consecutive_errors } : {},
                      ) } : {},
                      pls.tls != null ? { "tls" = merge(
                        { "mode" = pls.tls.mode },
                        pls.tls.credential_name != null ? { "credentialName" = pls.tls.credential_name } : {},
                        pls.tls.client_certificate != null ? { "clientCertificate" = pls.tls.client_certificate } : {},
                        pls.tls.private_key != null ? { "privateKey" = pls.tls.private_key } : {},
                        pls.tls.ca_certificates != null ? { "caCertificates" = pls.tls.ca_certificates } : {},
                        length(pls.tls.subject_alt_names) > 0 ? { "subjectAltNames" = pls.tls.subject_alt_names } : {},
                        pls.tls.min_protocol_version != null ? { "minProtocolVersion" = pls.tls.min_protocol_version } : {},
                        pls.tls.max_protocol_version != null ? { "maxProtocolVersion" = pls.tls.max_protocol_version } : {},
                        length(pls.tls.cipher_suites) > 0 ? { "cipherSuites" = pls.tls.cipher_suites } : {},
                        pls.tls.sni != null ? { "sni" = pls.tls.sni } : {},
                      ) } : {},
                    )
                  ]
                } : {},
              )
            } : {},
          )
        ]
      } : {},
      {
        "exportTo" = each.value.export_to
      },
    )
  }

  field_manager {
    force_conflicts = true
  }
}
