resource "kubernetes_manifest" "backend_config" {
  for_each = { for bc in var.backend_configs : bc.name => bc }

  manifest = {
    "apiVersion" = "cloud.google.com/v1"
    "kind"       = "BackendConfig"
    "metadata" = {
      "name"      = "${each.value.name}-backend-config"
      "namespace" = each.value.namespace
    }
    "spec" = merge(
      each.value.cdn_enabled ? {
        "cdn" = merge(
          {
            "cachePolicy" = {
              "includeHost"        = each.value.cdn_cache_policy.include_host
              "includeProtocol"    = each.value.cdn_cache_policy.include_protocol
              "includeQueryString" = each.value.cdn_cache_policy.include_query_string
            }
            "enabled" = each.value.cdn_enabled
          },
          each.value.cdn_cache_mode != null ? { "cacheMode" = each.value.cdn_cache_mode } : {},
          each.value.negative_caching ? {
            "negativeCaching" = each.value.negative_caching
          } : {},
          length(each.value.negative_caching_policy) > 0 ? {
            "negativeCachingPolicy" = each.value.negative_caching_policy
          } : {},
        )
      } : {},
      each.value.iap_enabled ? {
        "iap" = merge(
          {
            "enabled" = each.value.iap_enabled
          },
          each.value.iap_secret_name != null ? {
            "oauthclientCredentials" = {
              "secretName" = each.value.iap_secret_name
            }
          } : {},
        )
      } : {},
      each.value.cloudarmor_enabled ? {
        "securityPolicy" = {
          "name" = each.value.cloudarmor_custom_policy != null ? each.value.cloudarmor_custom_policy : "${each.value.name}-security-policy"
        }
      } : {},
      each.value.custom_request_headers != null ? {
        "customRequestHeaders" = {
          "headers" = each.value.custom_request_headers
        }
      } : {},
      each.value.custom_response_headers != null ? {
        "customResponseHeaders" = {
          "headers" = each.value.custom_response_headers
        }
      } : {},
      each.value.logging_enabled ? {
        "logging" = {
          "enable"     = each.value.logging_enabled
          "sampleRate" = each.value.logging_sample_rate
        }
      } : {},
      each.value.health_check != null ? {
        "healthCheck" = {
          "checkIntervalSec"   = each.value.health_check.check_interval_sec
          "timeoutSec"         = each.value.health_check.timeout_sec
          "healthyThreshold"   = each.value.health_check.healthy_threshold
          "unhealthyThreshold" = each.value.health_check.unhealthy_threshold
          "type"               = each.value.health_check.type
          "requestPath"        = each.value.health_check.request_path
          "port"               = each.value.health_check.port
        }
      } : {},
      each.value.session_affinity != null ? {
        "sessionAffinity" = {
          "affinityType"         = each.value.session_affinity.type
          "affinityCookieTtlSec" = each.value.session_affinity.cookie_ttl_sec
        }
      } : {},
      each.value.timeout_sec != null ? {
        "timeoutSec" = each.value.timeout_sec
      } : {},
      each.value.connection_draining != null ? {
        "connectionDraining" = {
          "drainingTimeoutSec" = each.value.connection_draining.draining_timeout_sec
        }
      } : {},
    )
  }

  field_manager {
    force_conflicts = true
  }
}
