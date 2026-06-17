mock_provider "kubernetes" {}

variables {
  gcp_gateway_policies = [
    {
      name                = "gw-policy"
      namespace           = "apps"
      allow_global_access = true
      ssl_policy          = "modern-tls"
      target_ref          = { name = "main-gateway" }
    }
  ]
}

run "plans_cleanly" { command = plan }

run "manifest" {
  command = plan
  assert {
    condition     = kubernetes_manifest.this["gw-policy"].manifest.kind == "GCPGatewayPolicy"
    error_message = "kind must be GCPGatewayPolicy."
  }
}
