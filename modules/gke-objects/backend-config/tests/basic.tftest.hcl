mock_provider "kubernetes" {}

variables {
  backend_configs = [
    {
      name                = "app"
      namespace           = "apps"
      timeout_sec         = 40
      connection_draining = { draining_timeout_sec = 60 }
    }
  ]
}

run "plans_cleanly" { command = plan }

run "manifest" {
  command = plan
  assert {
    condition     = kubernetes_manifest.backend_config["app"].manifest.spec.connectionDraining.drainingTimeoutSec == 60
    error_message = "connectionDraining.drainingTimeoutSec must be 60."
  }
}
