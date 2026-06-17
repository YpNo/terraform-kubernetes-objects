resource "kubernetes_manifest" "this" {
  for_each = { for bp in var.gcp_backend_policies : bp.name => bp }

  manifest = {
    "apiVersion" = "networking.gke.io/v1"
    "kind"       = "GCPBackendPolicy"
    "metadata" = {
      "name"        = each.value.name
      "namespace"   = each.value.namespace
      "labels"      = each.value.labels
      "annotations" = each.value.annotations
    }
    "spec" = {
      "default" = merge(
        each.value.backend_preference != null ? { "backendPreference" = each.value.backend_preference } : {},
        each.value.security_policy != null ? { "securityPolicy" = each.value.security_policy } : {},
        each.value.timeout_sec != null ? { "timeoutSec" = each.value.timeout_sec } : {},
        each.value.max_rate_per_endpoint != null ? { "maxRatePerEndpoint" = each.value.max_rate_per_endpoint } : {},
        each.value.logging != null ? {
          "logging" = merge(
            {
              "enabled" = each.value.logging.enabled
            },
            each.value.logging.sample_rate != null ? { "sampleRate" = each.value.logging.sample_rate } : {},
          )
        } : {},
        each.value.session_affinity != null ? {
          "sessionAffinity" = merge(
            {
              "type" = each.value.session_affinity.type
            },
            each.value.session_affinity.cookie_ttl_sec != null ? { "cookieTtlSec" = each.value.session_affinity.cookie_ttl_sec } : {},
          )
        } : {},
        each.value.connection_draining != null ? {
          "connectionDraining" = {
            "drainingTimeoutSec" = each.value.connection_draining.draining_timeout_sec
          }
        } : {},
        each.value.iap != null ? {
          "iap" = merge(
            {
              "enabled" = each.value.iap.enabled
            },
            each.value.iap.client_id != null ? { "clientID" = each.value.iap.client_id } : {},
            each.value.iap.oauth2_client_secret_name != null ? {
              "oauth2ClientSecret" = {
                "name" = each.value.iap.oauth2_client_secret_name
              }
            } : {},
          )
        } : {},
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
