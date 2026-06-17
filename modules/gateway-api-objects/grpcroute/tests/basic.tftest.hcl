# Unit tests for the grpcroute module (kubernetes_manifest, mocked provider).

mock_provider "kubernetes" {}

variables {
  grpc_routes = [
    {
      name        = "echo"
      namespace   = "apps"
      parent_refs = [{ name = "main-gateway" }]
      hostnames   = ["echo.example.com"]
      rules = [
        {
          matches      = [{ method = { type = "Exact", service = "echo.Echo", method = "Ping" } }]
          backend_refs = [{ name = "echo-svc", port = 9000 }]
        }
      ]
    }
  ]
}

run "plans_cleanly" {
  command = plan
}

run "renders_grpcroute_manifest" {
  command = plan

  assert {
    condition     = kubernetes_manifest.this["apps-echo"].manifest.kind == "GRPCRoute"
    error_message = "kind must be GRPCRoute."
  }

  assert {
    condition     = kubernetes_manifest.this["apps-echo"].manifest.apiVersion == "gateway.networking.k8s.io/v1"
    error_message = "apiVersion must be gateway.networking.k8s.io/v1."
  }

  assert {
    condition     = kubernetes_manifest.this["apps-echo"].manifest.metadata.name == "echo"
    error_message = "metadata.name must be 'echo'."
  }
}
