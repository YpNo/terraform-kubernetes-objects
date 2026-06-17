mock_provider "kubernetes" {}

variables {
  gcp_session_affinity_policies = [
    {
      name                      = "sap"
      namespace                 = "apps"
      stateful_generated_cookie = { cookie_ttl_seconds = 3600 }
      target_ref                = { name = "echo-svc" }
    }
  ]
}

run "plans_cleanly" { command = plan }

run "manifest" {
  command = plan
  assert {
    condition     = kubernetes_manifest.this["sap"].manifest.kind == "GCPSessionAffinityPolicy"
    error_message = "kind must be GCPSessionAffinityPolicy."
  }
  assert {
    condition     = kubernetes_manifest.this["sap"].manifest.spec.targetRef.name == "echo-svc"
    error_message = "targetRef.name must be echo-svc."
  }
}
