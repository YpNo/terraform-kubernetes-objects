# Unit tests for the tcproute module (kubernetes_manifest, mocked provider).

mock_provider "kubernetes" {}

variables {
  tcp_routes = [
    {
      name        = "echo"
      namespace   = "apps"
      parent_refs = [{ name = "main-gateway" }]
      rules = [
        {
          backend_refs = [{ name = "echo-svc", port = 9000 }]
        }
      ]
    }
  ]
}

run "plans_cleanly" {
  command = plan
}

run "renders_tcproute_manifest" {
  command = plan

  assert {
    condition     = kubernetes_manifest.this["apps-echo"].manifest.kind == "TCPRoute"
    error_message = "kind must be TCPRoute."
  }

  assert {
    condition     = kubernetes_manifest.this["apps-echo"].manifest.apiVersion == "gateway.networking.k8s.io/v1alpha2"
    error_message = "apiVersion must be gateway.networking.k8s.io/v1alpha2."
  }

  assert {
    condition     = kubernetes_manifest.this["apps-echo"].manifest.metadata.name == "echo"
    error_message = "metadata.name must be 'echo'."
  }
}
