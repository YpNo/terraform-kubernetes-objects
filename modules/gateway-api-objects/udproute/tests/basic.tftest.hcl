# Unit tests for the udproute module (kubernetes_manifest, mocked provider).

mock_provider "kubernetes" {}

variables {
  udp_routes = [
    {
      name        = "dns"
      namespace   = "apps"
      parent_refs = [{ name = "main-gateway" }]
      rules = [
        {
          backend_refs = [{ name = "dns-svc", port = 53 }]
        }
      ]
    }
  ]
}

run "plans_cleanly" {
  command = plan
}

run "renders_udproute_manifest" {
  command = plan

  assert {
    condition     = kubernetes_manifest.this["apps-dns"].manifest.kind == "UDPRoute"
    error_message = "kind must be UDPRoute."
  }

  assert {
    condition     = kubernetes_manifest.this["apps-dns"].manifest.apiVersion == "gateway.networking.k8s.io/v1alpha2"
    error_message = "apiVersion must be gateway.networking.k8s.io/v1alpha2."
  }

  assert {
    condition     = kubernetes_manifest.this["apps-dns"].manifest.metadata.name == "dns"
    error_message = "metadata.name must be 'dns'."
  }
}
