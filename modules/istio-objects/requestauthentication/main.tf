resource "kubernetes_manifest" "this" {
  for_each = { for ra in var.request_authentications : ra.name => ra }

  manifest = {
    "apiVersion" = "security.istio.io/v1beta1"
    "kind"       = "RequestAuthentication"
    "metadata" = merge(
      {
        "name"      = each.value.name
        "namespace" = each.value.namespace
      },
      each.value.labels != null ? { labels = each.value.labels } : {},
      each.value.annotations != null ? { annotations = each.value.annotations } : {},
    )
    "spec" = merge(
      each.value.selector != null ? { "selector" = { "matchLabels" = each.value.selector } } : {},
      length(each.value.jwt_rules) > 0 ? {
        "jwtRules" = [
          for jwt_rule in each.value.jwt_rules : merge(
            {
              "issuer" = jwt_rule.issuer
            },
            jwt_rule.jwks_uri != null ? { "jwksUri" = jwt_rule.jwks_uri } : {},
            jwt_rule.jwks != null ? { "jwks" = jwt_rule.jwks } : {},
            jwt_rule.output_payload_to_header != null ? { "outputPayloadToHeader" = jwt_rule.output_payload_to_header } : {},
            length(jwt_rule.audiences) > 0 ? { "audiences" = jwt_rule.audiences } : {},
            length(jwt_rule.from_headers) > 0 ? {
              "fromHeaders" = [
                for fh in jwt_rule.from_headers : merge(
                  { "name" = fh.name },
                  fh.prefix != null ? { "prefix" = fh.prefix } : {},
                )
              ]
            } : {},
            length(jwt_rule.from_params) > 0 ? { "fromParams" = jwt_rule.from_params } : {},
            length(jwt_rule.output_claim_to_headers) > 0 ? { "outputClaimToHeaders" = jwt_rule.output_claim_to_headers } : {},
            jwt_rule.forward_original_token != null ? { "forwardOriginalToken" = jwt_rule.forward_original_token } : {},
            # Legacy fields (Istio < 1.10) - include if explicitly provided
            jwt_rule.jwks_uri_alias != null ? { "jwksUriAlias" = jwt_rule.jwks_uri_alias } : {},
            jwt_rule.jwt_filter_expression != null ? { "jwtFilterExpression" = jwt_rule.jwt_filter_expression } : {},
          )
        ]
      } : {}
    )
  }

  field_manager {
    force_conflicts = true
  }
}
