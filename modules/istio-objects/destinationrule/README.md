# Destination Rule module for Istio/CSM/ASM

Istio `DestinationRule` configures what happens to traffic after routing to a service: load balancing, connection pools, outlier detection (circuit breaking), TLS settings, and named subsets. This module creates one or more rules from a `list(object)` input via `for_each`. Because these are Istio CRDs rendered through `kubernetes_manifest`, the Istio CRDs must already be installed and a cluster must be reachable at plan time.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.37.1 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.37.1 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [kubernetes_manifest.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_destination_rules"></a> [destination\_rules](#input\_destination\_rules) | A list of Istio DestinationRule configurations. | <pre>list(object({<br/>    name        = string<br/>    namespace   = string<br/>    labels      = optional(map(string))<br/>    annotations = optional(map(string))<br/>    host        = string # The service host to which the traffic policy/subsets apply (e.g., "my-service.my-namespace.svc.cluster.local" or "my-service")<br/><br/>    # Criteria to select the specific set of pods/VMs on which this DestinationRule applies.<br/>    workload_selector = optional(map(string)) # matchLabels<br/><br/>    # Inlined traffic_policy_type<br/>    traffic_policy = optional(object({<br/>      # Inlined load_balancer_type<br/>      load_balancer = optional(object({<br/>        simple = optional(string) # "ROUND_ROBIN", "LEAST_CONN", "RANDOM", "PASSTHROUGH"<br/>        # Inlined lb_consistent_hash_type<br/>        consistent_hash = optional(object({<br/>          http_header = optional(string)<br/>          # Inlined lb_consistent_hash_http_cookie_type<br/>          http_cookie = optional(object({<br/>            name = string<br/>            path = string<br/>            ttl  = string # e.g., "1h", "10m", "10s"<br/>          }))<br/>          use_source_ip        = optional(bool)<br/>          http_query_parameter = optional(string)<br/>        }))<br/>        warmup_duration_secs = optional(string) # Duration of slow-start warmup (e.g., "60s")<br/>        # Inlined locality_lb_setting_type<br/>        locality_lb_setting = optional(object({<br/>          enabled = optional(bool) # Enable locality load balancing<br/>          distribute = optional(list(object({<br/>            from = string      # Source locality (e.g., "region/zone/subzone")<br/>            to   = map(number) # Destination localities with weights<br/>          })), [])<br/>          failover = optional(list(object({<br/>            from = string # Source region<br/>            to   = string # Failover region<br/>          })), [])<br/>          failover_priority = optional(list(string), []) # Locality label keys for failover priority<br/>        }))<br/>      }))<br/>      # Inlined connection_pool_type<br/>      connection_pool = optional(object({<br/>        # Inlined http_connection_pool_type<br/>        http = optional(object({<br/>          http1_max_pending_requests  = optional(number)<br/>          http2_max_requests          = optional(number)<br/>          max_requests_per_connection = optional(number)<br/>          max_retries                 = optional(number)<br/>          idle_timeout                = optional(string) # e.g., "30s", "1m"<br/>          h2_upgrade_policy           = optional(string) # "DO_NOT_UPGRADE", "UPGRADE_DETECTION"<br/>        }))<br/>        # Inlined tcp_connection_pool_type<br/>        tcp = optional(object({<br/>          max_connections = optional(number)<br/>          connect_timeout = optional(string) # e.g., "10s"<br/>          # Inlined tcp_keepalive_type<br/>          tcp_keepalive = optional(object({<br/>            probes   = optional(number)<br/>            time     = optional(string) # e.g., "75s"<br/>            interval = optional(string) # e.g., "15s"<br/>          }))<br/>        }))<br/>      }))<br/>      # Inlined outlier_detection_type<br/>      outlier_detection = optional(object({<br/>        consecutive_5xx_errors             = optional(number)<br/>        consecutive_gateway_errors         = optional(number) # Deprecated in favor of consecutive_5xx_errors in newer Istio<br/>        consecutive_local_origin_failures  = optional(number) # Number of local origin failures before ejection<br/>        interval                           = optional(string) # e.g., "10s"<br/>        base_ejection_time                 = optional(string) # e.g., "30s"<br/>        max_ejection_percent               = optional(number) # 0-100<br/>        consecutive_errors                 = optional(number) # Generic consecutive errors<br/>        split_external_local_origin_errors = optional(bool)   # Distinguish local origin failures from upstream errors<br/>        min_health_percent                 = optional(number) # 0-100, panic threshold below which ejection stops<br/>      }))<br/>      # Inlined tls_client_settings_type<br/>      tls = optional(object({<br/>        mode                 = string                     # "DISABLE", "SIMPLE", "MUTUAL", "ISTIO_MUTUAL"<br/>        credential_name      = optional(string)           # Name of Kubernetes Secret<br/>        client_certificate   = optional(string)           # Path to client cert file (if not using credentialName)<br/>        private_key          = optional(string)           # Path to client key file (if not using credentialName)<br/>        ca_certificates      = optional(string)           # Path to CA certs file<br/>        subject_alt_names    = optional(list(string), []) # List of SANs<br/>        min_protocol_version = optional(string)           # "TLSV1_0", "TLSV1_1", "TLSV1_2", "TLSV1_3"<br/>        max_protocol_version = optional(string)           # "TLSV1_0", "TLSV1_1", "TLSV1_2", "TLSV1_3"<br/>        cipher_suites        = optional(list(string), [])<br/>        sni                  = optional(string) # SNI value to use<br/>      }))<br/>      # Inlined port_level_settings_type<br/>      port_level_settings = optional(list(object({<br/>        port_number = number # The port on the destination service<br/>        # Inlined load_balancer_type<br/>        load_balancer = optional(object({<br/>          simple = optional(string) # "ROUND_ROBIN", "LEAST_CONN", "RANDOM", "PASSTHROUGH"<br/>          # Inlined lb_consistent_hash_type<br/>          consistent_hash = optional(object({<br/>            http_header = optional(string)<br/>            # Inlined lb_consistent_hash_http_cookie_type<br/>            http_cookie = optional(object({<br/>              name = string<br/>              path = string<br/>              ttl  = string # e.g., "1h", "10m", "10s"<br/>            }))<br/>            use_source_ip        = optional(bool)<br/>            http_query_parameter = optional(string)<br/>          }))<br/>        }))<br/>        # Inlined connection_pool_type<br/>        connection_pool = optional(object({<br/>          # Inlined http_connection_pool_type<br/>          http = optional(object({<br/>            http1_max_pending_requests  = optional(number)<br/>            http2_max_requests          = optional(number)<br/>            max_requests_per_connection = optional(number)<br/>            max_retries                 = optional(number)<br/>            idle_timeout                = optional(string) # e.g., "30s", "1m"<br/>            h2_upgrade_policy           = optional(string) # "DO_NOT_UPGRADE", "UPGRADE_DETECTION"<br/>          }))<br/>          # Inlined tcp_connection_pool_type<br/>          tcp = optional(object({<br/>            max_connections = optional(number)<br/>            connect_timeout = optional(string) # e.g., "10s"<br/>            # Inlined tcp_keepalive_type<br/>            tcp_keepalive = optional(object({<br/>              probes   = optional(number)<br/>              time     = optional(string) # e.g., "75s"<br/>              interval = optional(string) # e.g., "15s"<br/>            }))<br/>          }))<br/>        }))<br/>        # Inlined outlier_detection_type<br/>        outlier_detection = optional(object({<br/>          consecutive_5xx_errors             = optional(number)<br/>          consecutive_gateway_errors         = optional(number) # Deprecated in favor of consecutive_5xx_errors in newer Istio<br/>          consecutive_local_origin_failures  = optional(number) # Number of local origin failures before ejection<br/>          interval                           = optional(string) # e.g., "10s"<br/>          base_ejection_time                 = optional(string) # e.g., "30s"<br/>          max_ejection_percent               = optional(number) # 0-100<br/>          consecutive_errors                 = optional(number) # Generic consecutive errors<br/>          split_external_local_origin_errors = optional(bool)   # Distinguish local origin failures from upstream errors<br/>          min_health_percent                 = optional(number) # 0-100, panic threshold below which ejection stops<br/>        }))<br/>        # Inlined tls_client_settings_type<br/>        tls = optional(object({<br/>          mode                 = string                     # "DISABLE", "SIMPLE", "MUTUAL", "ISTIO_MUTUAL"<br/>          credential_name      = optional(string)           # Name of Kubernetes Secret<br/>          client_certificate   = optional(string)           # Path to client cert file (if not using credentialName)<br/>          private_key          = optional(string)           # Path to client key file (if not using credentialName)<br/>          ca_certificates      = optional(string)           # Path to CA certs file<br/>          subject_alt_names    = optional(list(string), []) # List of SANs<br/>          min_protocol_version = optional(string)           # "TLSV1_0", "TLSV1_1", "TLSV1_2", "TLSV1_3"<br/>          max_protocol_version = optional(string)           # "TLSV1_0", "TLSV1_1", "TLSV1_2", "TLSV1_3"<br/>          cipher_suites        = optional(list(string), [])<br/>          sni                  = optional(string) # SNI value to use<br/>        }))<br/>      })), [])<br/>    }))<br/><br/>    subsets = optional(list(object({<br/>      name   = string<br/>      labels = optional(map(string), {}) # Corrected: Added default empty map<br/>      # Inlined traffic_policy_type<br/>      traffic_policy = optional(object({<br/>        # Inlined load_balancer_type<br/>        load_balancer = optional(object({<br/>          simple = optional(string) # "ROUND_ROBIN", "LEAST_CONN", "RANDOM", "PASSTHROUGH"<br/>          # Inlined lb_consistent_hash_type<br/>          consistent_hash = optional(object({<br/>            http_header = optional(string)<br/>            # Inlined lb_consistent_hash_http_cookie_type<br/>            http_cookie = optional(object({<br/>              name = string<br/>              path = string<br/>              ttl  = string # e.g., "1h", "10m", "10s"<br/>            }))<br/>            use_source_ip        = optional(bool)<br/>            http_query_parameter = optional(string)<br/>          }))<br/>        }))<br/>        # Inlined connection_pool_type<br/>        connection_pool = optional(object({<br/>          # Inlined http_connection_pool_type<br/>          http = optional(object({<br/>            http1_max_pending_requests  = optional(number)<br/>            http2_max_requests          = optional(number)<br/>            max_requests_per_connection = optional(number)<br/>            max_retries                 = optional(number)<br/>            idle_timeout                = optional(string) # e.g., "30s", "1m"<br/>            h2_upgrade_policy           = optional(string) # "DO_NOT_UPGRADE", "UPGRADE_DETECTION"<br/>          }))<br/>          # Inlined tcp_connection_pool_type<br/>          tcp = optional(object({<br/>            max_connections = optional(number)<br/>            connect_timeout = optional(string) # e.g., "10s"<br/>            # Inlined tcp_keepalive_type<br/>            tcp_keepalive = optional(object({<br/>              probes   = optional(number)<br/>              time     = optional(string) # e.g., "75s"<br/>              interval = optional(string) # e.g., "15s"<br/>            }))<br/>          }))<br/>        }))<br/>        # Inlined outlier_detection_type<br/>        outlier_detection = optional(object({<br/>          consecutive_5xx_errors             = optional(number)<br/>          consecutive_gateway_errors         = optional(number) # Deprecated in favor of consecutive_5xx_errors in newer Istio<br/>          consecutive_local_origin_failures  = optional(number) # Number of local origin failures before ejection<br/>          interval                           = optional(string) # e.g., "10s"<br/>          base_ejection_time                 = optional(string) # e.g., "30s"<br/>          max_ejection_percent               = optional(number) # 0-100<br/>          consecutive_errors                 = optional(number) # Generic consecutive errors<br/>          split_external_local_origin_errors = optional(bool)   # Distinguish local origin failures from upstream errors<br/>          min_health_percent                 = optional(number) # 0-100, panic threshold below which ejection stops<br/>        }))<br/>        # Inlined tls_client_settings_type<br/>        tls = optional(object({<br/>          mode                 = string                     # "DISABLE", "SIMPLE", "MUTUAL", "ISTIO_MUTUAL"<br/>          credential_name      = optional(string)           # Name of Kubernetes Secret<br/>          client_certificate   = optional(string)           # Path to client cert file (if not using credentialName)<br/>          private_key          = optional(string)           # Path to client key file (if not using credentialName)<br/>          ca_certificates      = optional(string)           # Path to CA certs file<br/>          subject_alt_names    = optional(list(string), []) # List of SANs<br/>          min_protocol_version = optional(string)           # "TLSV1_0", "TLSV1_1", "TLSV1_2", "TLSV1_3"<br/>          max_protocol_version = optional(string)           # "TLSV1_0", "TLSV1_1", "TLSV1_2", "TLSV1_3"<br/>          cipher_suites        = optional(list(string), [])<br/>          sni                  = optional(string) # SNI value to use<br/>        }))<br/>        # Inlined port_level_settings_type<br/>        port_level_settings = optional(list(object({<br/>          port_number = number # The port on the destination service<br/>          # Inlined load_balancer_type<br/>          load_balancer = optional(object({<br/>            simple = optional(string) # "ROUND_ROBIN", "LEAST_CONN", "RANDOM", "PASSTHROUGH"<br/>            # Inlined lb_consistent_hash_type<br/>            consistent_hash = optional(object({<br/>              http_header = optional(string)<br/>              # Inlined lb_consistent_hash_http_cookie_type<br/>              http_cookie = optional(object({<br/>                name = string<br/>                path = string<br/>                ttl  = string # e.g., "1h", "10m", "10s"<br/>              }))<br/>              use_source_ip        = optional(bool)<br/>              http_query_parameter = optional(string)<br/>            }))<br/>          }))<br/>          # Inlined connection_pool_type<br/>          connection_pool = optional(object({<br/>            # Inlined http_connection_pool_type<br/>            http = optional(object({<br/>              http1_max_pending_requests  = optional(number)<br/>              http2_max_requests          = optional(number)<br/>              max_requests_per_connection = optional(number)<br/>              max_retries                 = optional(number)<br/>              idle_timeout                = optional(string) # e.g., "30s", "1m"<br/>              h2_upgrade_policy           = optional(string) # "DO_NOT_UPGRADE", "UPGRADE_DETECTION"<br/>            }))<br/>            # Inlined tcp_connection_pool_type<br/>            tcp = optional(object({<br/>              max_connections = optional(number)<br/>              connect_timeout = optional(string) # e.g., "10s"<br/>              # Inlined tcp_keepalive_type<br/>              tcp_keepalive = optional(object({<br/>                probes   = optional(number)<br/>                time     = optional(string) # e.g., "75s"<br/>                interval = optional(string) # e.g., "15s"<br/>              }))<br/>            }))<br/>          }))<br/>          # Inlined outlier_detection_type<br/>          outlier_detection = optional(object({<br/>            consecutive_5xx_errors     = optional(number)<br/>            consecutive_gateway_errors = optional(number) # Deprecated in favor of consecutive_5xx_errors in newer Istio<br/>            interval                   = optional(string) # e.g., "10s"<br/>            base_ejection_time         = optional(string) # e.g., "30s"<br/>            max_ejection_percent       = optional(number) # 0-100<br/>            consecutive_errors         = optional(number) # Generic consecutive errors<br/>          }))<br/>          # Inlined tls_client_settings_type<br/>          tls = optional(object({<br/>            mode                 = string                     # "DISABLE", "SIMPLE", "MUTUAL", "ISTIO_MUTUAL"<br/>            credential_name      = optional(string)           # Name of Kubernetes Secret<br/>            client_certificate   = optional(string)           # Path to client cert file (if not using credentialName)<br/>            private_key          = optional(string)           # Path to client key file (if not using credentialName)<br/>            ca_certificates      = optional(string)           # Path to CA certs file<br/>            subject_alt_names    = optional(list(string), []) # List of SANs<br/>            min_protocol_version = optional(string)           # "TLSV1_0", "TLSV1_1", "TLSV1_2", "TLSV1_3"<br/>            max_protocol_version = optional(string)           # "TLSV1_0", "TLSV1_1", "TLSV1_2", "TLSV1_3"<br/>            cipher_suites        = optional(list(string), [])<br/>            sni                  = optional(string) # SNI value to use<br/>          }))<br/>        })), [])<br/>      }))<br/>    })), [])<br/><br/>    export_to = optional(list(string), ["*"])<br/>  }))</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage

### with Terraform

```terraform
module "destinationrule" {
  source = "github.com/YpNo/terraform-kubernetes-objects//modules/istio-objects/destinationrule?ref=v0.1.0"

  destination_rules = [
    {
      name        = "my-service-dr"
      namespace   = "default"
      host        = "my-service.default.svc.cluster.local"
      traffic_policy = {
        load_balancer = {
          simple = "ROUND_ROBIN"
        }
        connection_pool = {
          http = {
            http1_max_pending_requests = 100
            idle_timeout               = "60s"
          },
          tcp = {
            max_connections = 50
            connect_timeout = "5s"
            tcp_keepalive = {
              probes = 3
              time   = "30s"
              interval = "10s"
            }
          }
        }
        outlier_detection = {
          consecutive_5xx_errors = 5
          interval               = "10s"
          base_ejection_time     = "30s"
          max_ejection_percent   = 100
        }
        tls = {
          mode              = "ISTIO_MUTUAL"
          client_certificate = "path/to/client-cert.pem" # Only if not using credential_name
          private_key        = "path/to/client-key.pem"  # Only if not using credential_name
          ca_certificates    = "path/to/ca-certs.pem"
          sni                = "my-service.default.svc.cluster.local"
        }
        port_level_settings = [
          {
            port_number = 80
            load_balancer = {
              simple = "LEAST_CONN"
            }
          },
          {
            port_number = 9080
            connection_pool = {
              http = {
                http2_max_requests = 50
              }
            }
          }
        ]
      }
      subsets = [
        {
          name   = "v1"
          labels = { "version" = "v1" }
          traffic_policy = {
            load_balancer = {
              simple = "RANDOM"
            }
          }
        },
        {
          name   = "v2"
          labels = { "version" = "v2" }
          traffic_policy = {
            connection_pool = {
              http = {
                max_requests_per_connection = 1
              }
            }
          }
        }
      ]
    },
    {
      name        = "another-service-dr"
      namespace   = "prod"
      host        = "another-service"
      subsets = [
        {
          name   = "stable"
          labels = { "environment" = "production" }
        }
      ]
    }
  ]
}
```

### with Terragrunt

```terraform
...

inputs = { 
  destination_rules = [
    {
      name        = "my-service-dr"
      namespace   = "default"
      host        = "my-service.default.svc.cluster.local"
      traffic_policy = {
        load_balancer = {
          simple = "ROUND_ROBIN"
        }
        connection_pool = {
          http = {
            http1_max_pending_requests = 100
            idle_timeout               = "60s"
          },
          tcp = {
            max_connections = 50
            connect_timeout = "5s"
            tcp_keepalive = {
              probes = 3
              time   = "30s"
              interval = "10s"
            }
          }
        }
        outlier_detection = {
          consecutive_5xx_errors = 5
          interval               = "10s"
          base_ejection_time     = "30s"
          max_ejection_percent   = 100
        }
        tls = {
          mode              = "ISTIO_MUTUAL"
          client_certificate = "path/to/client-cert.pem" # Only if not using credential_name
          private_key        = "path/to/client-key.pem"  # Only if not using credential_name
          ca_certificates    = "path/to/ca-certs.pem"
          sni                = "my-service.default.svc.cluster.local"
        }
        port_level_settings = [
          {
            port_number = 80
            load_balancer = {
              simple = "LEAST_CONN"
            }
          },
          {
            port_number = 9080
            connection_pool = {
              http = {
                http2_max_requests = 50
              }
            }
          }
        ]
      }
      subsets = [
        {
          name   = "v1"
          labels = { "version" = "v1" }
          traffic_policy = {
            load_balancer = {
              simple = "RANDOM"
            }
          }
        },
        {
          name   = "v2"
          labels = { "version" = "v2" }
          traffic_policy = {
            connection_pool = {
              http = {
                max_requests_per_connection = 1
              }
            }
          }
        }
      ]
    },
    {
      name        = "another-service-dr"
      namespace   = "prod"
      host        = "another-service"
      subsets = [
        {
          name   = "stable"
          labels = { "environment" = "production" }
        }
      ]
    }
  ]
}
```
