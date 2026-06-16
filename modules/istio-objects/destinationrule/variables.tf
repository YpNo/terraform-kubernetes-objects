variable "destination_rules" {
  description = "A list of Istio DestinationRule configurations."
  type = list(object({
    name        = string
    namespace   = string
    labels      = optional(map(string))
    annotations = optional(map(string))
    host        = string # The service host to which the traffic policy/subsets apply (e.g., "my-service.my-namespace.svc.cluster.local" or "my-service")

    # Inlined traffic_policy_type
    traffic_policy = optional(object({
      # Inlined load_balancer_type
      load_balancer = optional(object({
        simple = optional(string) # "ROUND_ROBIN", "LEAST_CONN", "RANDOM", "PASSTHROUGH"
        # Inlined lb_consistent_hash_type
        consistent_hash = optional(object({
          http_header = optional(string)
          # Inlined lb_consistent_hash_http_cookie_type
          http_cookie = optional(object({
            name = string
            path = string
            ttl  = string # e.g., "1h", "10m", "10s"
          }))
          use_source_ip        = optional(bool)
          http_query_parameter = optional(string)
        }))
      }))
      # Inlined connection_pool_type
      connection_pool = optional(object({
        # Inlined http_connection_pool_type
        http = optional(object({
          http1_max_pending_requests  = optional(number)
          http2_max_requests          = optional(number)
          max_requests_per_connection = optional(number)
          max_retries                 = optional(number)
          idle_timeout                = optional(string) # e.g., "30s", "1m"
          h2_upgrade_policy           = optional(string) # "DO_NOT_UPGRADE", "UPGRADE_DETECTION"
        }))
        # Inlined tcp_connection_pool_type
        tcp = optional(object({
          max_connections = optional(number)
          connect_timeout = optional(string) # e.g., "10s"
          # Inlined tcp_keepalive_type
          tcp_keepalive = optional(object({
            probes   = optional(number)
            time     = optional(string) # e.g., "75s"
            interval = optional(string) # e.g., "15s"
          }))
        }))
      }))
      # Inlined outlier_detection_type
      outlier_detection = optional(object({
        consecutive_5xx_errors     = optional(number)
        consecutive_gateway_errors = optional(number) # Deprecated in favor of consecutive_5xx_errors in newer Istio
        interval                   = optional(string) # e.g., "10s"
        base_ejection_time         = optional(string) # e.g., "30s"
        max_ejection_percent       = optional(number) # 0-100
        consecutive_errors         = optional(number) # Generic consecutive errors
      }))
      # Inlined tls_client_settings_type
      tls = optional(object({
        mode                 = string                     # "DISABLE", "SIMPLE", "MUTUAL", "ISTIO_MUTUAL"
        credential_name      = optional(string)           # Name of Kubernetes Secret
        client_certificate   = optional(string)           # Path to client cert file (if not using credentialName)
        private_key          = optional(string)           # Path to client key file (if not using credentialName)
        ca_certificates      = optional(string)           # Path to CA certs file
        subject_alt_names    = optional(list(string), []) # List of SANs
        min_protocol_version = optional(string)           # "TLSV1_0", "TLSV1_1", "TLSV1_2", "TLSV1_3"
        max_protocol_version = optional(string)           # "TLSV1_0", "TLSV1_1", "TLSV1_2", "TLSV1_3"
        cipher_suites        = optional(list(string), [])
        sni                  = optional(string) # SNI value to use
      }))
      # Inlined port_level_settings_type
      port_level_settings = optional(list(object({
        port_number = number # The port on the destination service
        # Inlined load_balancer_type
        load_balancer = optional(object({
          simple = optional(string) # "ROUND_ROBIN", "LEAST_CONN", "RANDOM", "PASSTHROUGH"
          # Inlined lb_consistent_hash_type
          consistent_hash = optional(object({
            http_header = optional(string)
            # Inlined lb_consistent_hash_http_cookie_type
            http_cookie = optional(object({
              name = string
              path = string
              ttl  = string # e.g., "1h", "10m", "10s"
            }))
            use_source_ip        = optional(bool)
            http_query_parameter = optional(string)
          }))
        }))
        # Inlined connection_pool_type
        connection_pool = optional(object({
          # Inlined http_connection_pool_type
          http = optional(object({
            http1_max_pending_requests  = optional(number)
            http2_max_requests          = optional(number)
            max_requests_per_connection = optional(number)
            max_retries                 = optional(number)
            idle_timeout                = optional(string) # e.g., "30s", "1m"
            h2_upgrade_policy           = optional(string) # "DO_NOT_UPGRADE", "UPGRADE_DETECTION"
          }))
          # Inlined tcp_connection_pool_type
          tcp = optional(object({
            max_connections = optional(number)
            connect_timeout = optional(string) # e.g., "10s"
            # Inlined tcp_keepalive_type
            tcp_keepalive = optional(object({
              probes   = optional(number)
              time     = optional(string) # e.g., "75s"
              interval = optional(string) # e.g., "15s"
            }))
          }))
        }))
        # Inlined outlier_detection_type
        outlier_detection = optional(object({
          consecutive_5xx_errors     = optional(number)
          consecutive_gateway_errors = optional(number) # Deprecated in favor of consecutive_5xx_errors in newer Istio
          interval                   = optional(string) # e.g., "10s"
          base_ejection_time         = optional(string) # e.g., "30s"
          max_ejection_percent       = optional(number) # 0-100
          consecutive_errors         = optional(number) # Generic consecutive errors
        }))
        # Inlined tls_client_settings_type
        tls = optional(object({
          mode                 = string                     # "DISABLE", "SIMPLE", "MUTUAL", "ISTIO_MUTUAL"
          credential_name      = optional(string)           # Name of Kubernetes Secret
          client_certificate   = optional(string)           # Path to client cert file (if not using credentialName)
          private_key          = optional(string)           # Path to client key file (if not using credentialName)
          ca_certificates      = optional(string)           # Path to CA certs file
          subject_alt_names    = optional(list(string), []) # List of SANs
          min_protocol_version = optional(string)           # "TLSV1_0", "TLSV1_1", "TLSV1_2", "TLSV1_3"
          max_protocol_version = optional(string)           # "TLSV1_0", "TLSV1_1", "TLSV1_2", "TLSV1_3"
          cipher_suites        = optional(list(string), [])
          sni                  = optional(string) # SNI value to use
        }))
      })), [])
    }))

    subsets = optional(list(object({
      name   = string
      labels = optional(map(string), {}) # Corrected: Added default empty map
      # Inlined traffic_policy_type
      traffic_policy = optional(object({
        # Inlined load_balancer_type
        load_balancer = optional(object({
          simple = optional(string) # "ROUND_ROBIN", "LEAST_CONN", "RANDOM", "PASSTHROUGH"
          # Inlined lb_consistent_hash_type
          consistent_hash = optional(object({
            http_header = optional(string)
            # Inlined lb_consistent_hash_http_cookie_type
            http_cookie = optional(object({
              name = string
              path = string
              ttl  = string # e.g., "1h", "10m", "10s"
            }))
            use_source_ip        = optional(bool)
            http_query_parameter = optional(string)
          }))
        }))
        # Inlined connection_pool_type
        connection_pool = optional(object({
          # Inlined http_connection_pool_type
          http = optional(object({
            http1_max_pending_requests  = optional(number)
            http2_max_requests          = optional(number)
            max_requests_per_connection = optional(number)
            max_retries                 = optional(number)
            idle_timeout                = optional(string) # e.g., "30s", "1m"
            h2_upgrade_policy           = optional(string) # "DO_NOT_UPGRADE", "UPGRADE_DETECTION"
          }))
          # Inlined tcp_connection_pool_type
          tcp = optional(object({
            max_connections = optional(number)
            connect_timeout = optional(string) # e.g., "10s"
            # Inlined tcp_keepalive_type
            tcp_keepalive = optional(object({
              probes   = optional(number)
              time     = optional(string) # e.g., "75s"
              interval = optional(string) # e.g., "15s"
            }))
          }))
        }))
        # Inlined outlier_detection_type
        outlier_detection = optional(object({
          consecutive_5xx_errors     = optional(number)
          consecutive_gateway_errors = optional(number) # Deprecated in favor of consecutive_5xx_errors in newer Istio
          interval                   = optional(string) # e.g., "10s"
          base_ejection_time         = optional(string) # e.g., "30s"
          max_ejection_percent       = optional(number) # 0-100
          consecutive_errors         = optional(number) # Generic consecutive errors
        }))
        # Inlined tls_client_settings_type
        tls = optional(object({
          mode                 = string                     # "DISABLE", "SIMPLE", "MUTUAL", "ISTIO_MUTUAL"
          credential_name      = optional(string)           # Name of Kubernetes Secret
          client_certificate   = optional(string)           # Path to client cert file (if not using credentialName)
          private_key          = optional(string)           # Path to client key file (if not using credentialName)
          ca_certificates      = optional(string)           # Path to CA certs file
          subject_alt_names    = optional(list(string), []) # List of SANs
          min_protocol_version = optional(string)           # "TLSV1_0", "TLSV1_1", "TLSV1_2", "TLSV1_3"
          max_protocol_version = optional(string)           # "TLSV1_0", "TLSV1_1", "TLSV1_2", "TLSV1_3"
          cipher_suites        = optional(list(string), [])
          sni                  = optional(string) # SNI value to use
        }))
        # Inlined port_level_settings_type
        port_level_settings = optional(list(object({
          port_number = number # The port on the destination service
          # Inlined load_balancer_type
          load_balancer = optional(object({
            simple = optional(string) # "ROUND_ROBIN", "LEAST_CONN", "RANDOM", "PASSTHROUGH"
            # Inlined lb_consistent_hash_type
            consistent_hash = optional(object({
              http_header = optional(string)
              # Inlined lb_consistent_hash_http_cookie_type
              http_cookie = optional(object({
                name = string
                path = string
                ttl  = string # e.g., "1h", "10m", "10s"
              }))
              use_source_ip        = optional(bool)
              http_query_parameter = optional(string)
            }))
          }))
          # Inlined connection_pool_type
          connection_pool = optional(object({
            # Inlined http_connection_pool_type
            http = optional(object({
              http1_max_pending_requests  = optional(number)
              http2_max_requests          = optional(number)
              max_requests_per_connection = optional(number)
              max_retries                 = optional(number)
              idle_timeout                = optional(string) # e.g., "30s", "1m"
              h2_upgrade_policy           = optional(string) # "DO_NOT_UPGRADE", "UPGRADE_DETECTION"
            }))
            # Inlined tcp_connection_pool_type
            tcp = optional(object({
              max_connections = optional(number)
              connect_timeout = optional(string) # e.g., "10s"
              # Inlined tcp_keepalive_type
              tcp_keepalive = optional(object({
                probes   = optional(number)
                time     = optional(string) # e.g., "75s"
                interval = optional(string) # e.g., "15s"
              }))
            }))
          }))
          # Inlined outlier_detection_type
          outlier_detection = optional(object({
            consecutive_5xx_errors     = optional(number)
            consecutive_gateway_errors = optional(number) # Deprecated in favor of consecutive_5xx_errors in newer Istio
            interval                   = optional(string) # e.g., "10s"
            base_ejection_time         = optional(string) # e.g., "30s"
            max_ejection_percent       = optional(number) # 0-100
            consecutive_errors         = optional(number) # Generic consecutive errors
          }))
          # Inlined tls_client_settings_type
          tls = optional(object({
            mode                 = string                     # "DISABLE", "SIMPLE", "MUTUAL", "ISTIO_MUTUAL"
            credential_name      = optional(string)           # Name of Kubernetes Secret
            client_certificate   = optional(string)           # Path to client cert file (if not using credentialName)
            private_key          = optional(string)           # Path to client key file (if not using credentialName)
            ca_certificates      = optional(string)           # Path to CA certs file
            subject_alt_names    = optional(list(string), []) # List of SANs
            min_protocol_version = optional(string)           # "TLSV1_0", "TLSV1_1", "TLSV1_2", "TLSV1_3"
            max_protocol_version = optional(string)           # "TLSV1_0", "TLSV1_1", "TLSV1_2", "TLSV1_3"
            cipher_suites        = optional(list(string), [])
            sni                  = optional(string) # SNI value to use
          }))
        })), [])
      }))
    })), [])

    export_to = optional(list(string), ["*"])
  }))

  validation {
    condition = alltrue([
      for dr_item in var.destination_rules :
      try(dr_item.traffic_policy.load_balancer, null) == null ||
      contains(["ROUND_ROBIN", "LEAST_CONN", "RANDOM", "PASSTHROUGH"],
      try(dr_item.traffic_policy.load_balancer.simple, "N/A"))
    ])
    error_message = "Invalid 'simple' load balancer algorithm for top-level trafficPolicy. Must be one of: 'ROUND_ROBIN', 'LEAST_CONN', 'RANDOM', 'PASSTHROUGH'."
  }

  validation {
    condition = alltrue([
      for dr_item in var.destination_rules :
      try(dr_item.traffic_policy.connection_pool.http, null) == null ||
      contains(["DO_NOT_UPGRADE", "UPGRADE_DETECTION"],
      try(dr_item.traffic_policy.connection_pool.http.h2_upgrade_policy, "N/A"))
    ])
    error_message = "Invalid 'h2_upgrade_policy' for top-level HTTP connection pool. Must be one of: 'DO_NOT_UPGRADE', 'UPGRADE_DETECTION'."
  }

  validation {
    condition = alltrue([
      for dr_item in var.destination_rules :
      try(dr_item.traffic_policy.tls, null) == null ||
      contains(["DISABLE", "SIMPLE", "MUTUAL", "ISTIO_MUTUAL"],
      try(dr_item.traffic_policy.tls.mode, "N/A"))
    ])
    error_message = "Invalid 'mode' for top-level TLS client settings. Must be one of: 'DISABLE', 'SIMPLE', 'MUTUAL', 'ISTIO_MUTUAL'."
  }

  # Add more validations for nested types (subsets, port_level_settings) if critical

  validation {
    condition = alltrue([
      for dr_item in var.destination_rules :
      alltrue([
        for subset in try(dr_item.subsets, []) :
        try(subset.traffic_policy.load_balancer, null) == null ||
        contains(["ROUND_ROBIN", "LEAST_CONN", "RANDOM", "PASSTHROUGH"],
        try(subset.traffic_policy.load_balancer.simple, "N/A"))
      ])
    ])
    error_message = "Invalid 'simple' load balancer algorithm for subset trafficPolicy. Must be one of: 'ROUND_ROBIN', 'LEAST_CONN', 'RANDOM', 'PASSTHROUGH'."
  }

  validation {
    condition = alltrue([
      for dr_item in var.destination_rules :
      alltrue([
        for subset in try(dr_item.subsets, []) :
        try(subset.traffic_policy.connection_pool.http, null) == null ||
        contains(["DO_NOT_UPGRADE", "UPGRADE_DETECTION"],
        try(subset.traffic_policy.connection_pool.http.h2_upgrade_policy, "N/A"))
      ])
    ])
    error_message = "Invalid 'h2_upgrade_policy' for subset HTTP connection pool. Must be one of: 'DO_NOT_UPGRADE', 'UPGRADE_DETECTION'."
  }

  validation {
    condition = alltrue([
      for dr_item in var.destination_rules :
      alltrue([
        for subset in try(dr_item.subsets, []) :
        try(subset.traffic_policy.tls, null) == null ||
        contains(["DISABLE", "SIMPLE", "MUTUAL", "ISTIO_MUTUAL"],
        try(subset.traffic_policy.tls.mode, "N/A"))
      ])
    ])
    error_message = "Invalid 'mode' for subset TLS client settings. Must be one of: 'DISABLE', 'SIMPLE', 'MUTUAL', 'ISTIO_MUTUAL'."
  }

  validation {
    condition = alltrue([
      for dr_item in var.destination_rules :
      alltrue([
        for subset in try(dr_item.subsets, []) :
        alltrue([
          for pls in try(subset.traffic_policy.port_level_settings, []) :
          try(pls.load_balancer, null) == null ||
          contains(["ROUND_ROBIN", "LEAST_CONN", "RANDOM", "PASSTHROUGH"],
          try(pls.load_balancer.simple, "N/A"))
        ])
      ])
    ])
    error_message = "Invalid 'simple' load balancer algorithm for port-level trafficPolicy. Must be one of: 'ROUND_ROBIN', 'LEAST_CONN', 'RANDOM', 'PASSTHROUGH'."
  }

  validation {
    condition = alltrue([
      for dr_item in var.destination_rules :
      alltrue([
        for subset in try(dr_item.subsets, []) :
        alltrue([
          for pls in try(subset.traffic_policy.port_level_settings, []) :
          try(pls.connection_pool.http, null) == null ||
          contains(["DO_NOT_UPGRADE", "UPGRADE_DETECTION"],
          try(pls.connection_pool.http.h2_upgrade_policy, "N/A"))
        ])
      ])
    ])
    error_message = "Invalid 'h2_upgrade_policy' for port-level HTTP connection pool. Must be one of: 'DO_NOT_UPGRADE', 'UPGRADE_DETECTION'."
  }

  validation {
    condition = alltrue([
      for dr_item in var.destination_rules :
      alltrue([
        for subset in try(dr_item.subsets, []) :
        alltrue([
          for pls in try(subset.traffic_policy.port_level_settings, []) :
          try(pls.tls, null) == null ||
          contains(["DISABLE", "SIMPLE", "MUTUAL", "ISTIO_MUTUAL"],
          try(pls.tls.mode, "N/A"))
        ])
      ])
    ])
    error_message = "Invalid 'mode' for port-level TLS client settings. Must be one of: 'DISABLE', 'SIMPLE', 'MUTUAL', 'ISTIO_MUTUAL'."
  }
}
