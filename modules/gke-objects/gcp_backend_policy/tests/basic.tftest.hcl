mock_provider "kubernetes" {}

variables {
  gcp_backend_policies = [
    {
      name                = "be-policy"
      namespace           = "apps"
      timeout_sec         = 30
      logging             = { enabled = true, sample_rate = 1000000 }
      connection_draining = { draining_timeout_sec = 60 }
      target_ref          = { name = "echo-svc" }
    }
  ]
}

run "plans_cleanly" { command = plan }

run "manifest" {
  command = plan
  assert {
    condition     = kubernetes_manifest.this["be-policy"].manifest.kind == "GCPBackendPolicy"
    error_message = "kind must be GCPBackendPolicy."
  }
  assert {
    condition     = kubernetes_manifest.this["be-policy"].manifest.spec.targetRef.name == "echo-svc"
    error_message = "targetRef.name must be echo-svc."
  }
}
