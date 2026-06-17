mock_provider "kubernetes" {}

variables {
  gcp_session_affinity_filters = [
    {
      name                      = "saf"
      namespace                 = "apps"
      stateful_generated_cookie = { cookie_ttl_seconds = 3600 }
    }
  ]
}

run "plans_cleanly" { command = plan }

run "manifest" {
  command = plan
  assert {
    condition     = kubernetes_manifest.this["saf"].manifest.kind == "GCPSessionAffinityFilter"
    error_message = "kind must be GCPSessionAffinityFilter."
  }
  assert {
    condition     = kubernetes_manifest.this["saf"].manifest.spec.statefulGeneratedCookie.cookieTtlSeconds == 3600
    error_message = "cookieTtlSeconds must be 3600."
  }
}
