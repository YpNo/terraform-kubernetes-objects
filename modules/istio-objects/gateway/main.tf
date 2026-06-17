# istio-gateway/main.tf (CORRECTED)
resource "kubernetes_manifest" "this" {
  for_each = { for gw in var.gateways : gw.name => gw }

  manifest = {
    "apiVersion" = "networking.istio.io/v1beta1"
    "kind"       = "Gateway"
    "metadata" = merge(
      {
        "name"      = each.value.name
        "namespace" = each.value.namespace
      },
      each.value.labels != null ? { "labels" = each.value.labels } : {},
      each.value.annotations != null ? { "annotations" = each.value.annotations } : {},
    )
    "spec" = {
      "selector" = each.value.selector # e.g., {"istio": "ingressgateway"}
      "servers" = [
        for server in each.value.servers : merge( # Merge directly into the server map
          {
            "port" = {
              "number"   = server.port.number
              "name"     = server.port.name
              "protocol" = server.port.protocol
            }
            "hosts" = server.hosts
          },
          # Only include TLS block if it's provided
          server.tls != null ? {
            "tls" = merge(
              { "mode" = server.tls.mode }, # Start with mode, as it's always required if TLS is present
              server.tls.credential_name != null ? { "credentialName" = server.tls.credential_name } : {},
              server.tls.private_key != null ? { "privateKey" = server.tls.private_key } : {},
              server.tls.server_certificate != null ? { "serverCertificate" = server.tls.server_certificate } : {},
              server.tls.ca_certificates != null ? { "caCertificates" = server.tls.ca_certificates } : {},
              length(server.tls.subject_alt_names) > 0 ? { "subjectAltNames" = server.tls.subject_alt_names } : {},
              server.tls.min_protocol_version != null ? { "minProtocolVersion" = server.tls.min_protocol_version } : {},
              server.tls.max_protocol_version != null ? { "maxProtocolVersion" = server.tls.max_protocol_version } : {},
              length(server.tls.cipher_suites) > 0 ? { "cipherSuites" = server.tls.cipher_suites } : {},
              server.tls.credential_source != null ? { "credentialSource" = server.tls.credential_source } : {},
            )
          } : {}
        )
      ]
    }
  }

  field_manager {
    force_conflicts = true
  }
}
