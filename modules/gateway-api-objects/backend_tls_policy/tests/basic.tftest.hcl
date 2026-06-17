mock_provider "kubernetes" {}

variables {
  backend_tls_policies = [
    {
      name        = "be-tls"
      namespace   = "apps"
      target_refs = [{ name = "echo-svc" }]
      validation = {
        hostname            = "echo.example.com"
        ca_certificate_refs = [{ name = "ca-bundle" }]
      }
    }
  ]
}

run "plans_cleanly" { command = plan }

run "manifest" {
  command = plan
  assert {
    condition     = kubernetes_manifest.this["apps-be-tls"].manifest.kind == "BackendTLSPolicy"
    error_message = "kind must be BackendTLSPolicy."
  }
  assert {
    condition     = kubernetes_manifest.this["apps-be-tls"].manifest.spec.validation.hostname == "echo.example.com"
    error_message = "validation.hostname must match."
  }
}
