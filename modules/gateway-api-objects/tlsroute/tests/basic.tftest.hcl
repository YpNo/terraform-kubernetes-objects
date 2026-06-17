# Unit tests for the tlsroute module (kubernetes_manifest, mocked provider).

mock_provider "kubernetes" {}

variables {
  tls_routes = [
    {
      name        = "secure"
      namespace   = "apps"
      parent_refs = [{ name = "main-gateway" }]
      hostnames   = ["secure.example.com"]
      rules = [
        {
          backend_refs = [{ name = "secure-svc", port = 8443 }]
        }
      ]
    }
  ]
}

run "plans_cleanly" {
  command = plan
}

run "renders_tlsroute_manifest" {
  command = plan

  assert {
    condition     = kubernetes_manifest.this["apps-secure"].manifest.kind == "TLSRoute"
    error_message = "kind must be TLSRoute."
  }

  assert {
    condition     = kubernetes_manifest.this["apps-secure"].manifest.apiVersion == "gateway.networking.k8s.io/v1alpha2"
    error_message = "apiVersion must be gateway.networking.k8s.io/v1alpha2."
  }

  assert {
    condition     = kubernetes_manifest.this["apps-secure"].manifest.spec.hostnames[0] == "secure.example.com"
    error_message = "hostnames[0] must be 'secure.example.com'."
  }
}
