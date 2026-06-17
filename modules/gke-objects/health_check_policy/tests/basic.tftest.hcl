mock_provider "kubernetes" {}

variables {
  health_check_policies = [
    {
      name               = "hc"
      namespace          = "apps"
      check_interval_sec = 10
      config = {
        type              = "HTTP"
        http_health_check = { port = 8080, request_path = "/healthz" }
      }
      target_ref = { name = "echo-svc" }
    }
  ]
}

run "plans_cleanly" { command = plan }

run "manifest" {
  command = plan
  assert {
    condition     = kubernetes_manifest.this["hc"].manifest.kind == "HealthCheckPolicy"
    error_message = "kind must be HealthCheckPolicy."
  }
}
