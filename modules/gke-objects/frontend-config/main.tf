resource "kubernetes_manifest" "frontend_config" {
  for_each = { for fc in var.frontend_configs : fc.name => fc }

  # FrontendConfig can only be used with External Ingresses. Except for SSL Policy with Gateway API.
  manifest = {
    "apiVersion" = "networking.gke.io/v1beta1"
    "kind"       = "FrontendConfig"
    "metadata" = {
      "name"      = "${each.value.name}-frontend-config"
      "namespace" = each.value.namespace
    }
    "spec" = merge(
      each.value.ssl_policy != null ? { "sslPolicy" = each.value.ssl_policy } : {},
      each.value.redirect_to_https ? { "redirectToHttps" = merge({
        "enabled" = each.value.redirect_to_https
        },
        each.value.redirect_to_https && each.value.redirect_to_https_response_code_name != null ? { "responseCodeName" = each.value.redirect_to_https_response_code_name } : {},
    ) } : {}, )
  }

  field_manager {
    force_conflicts = true
  }
}
