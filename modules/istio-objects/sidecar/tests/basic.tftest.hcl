mock_provider "kubernetes" {}

variables {
  sidecars = [
    {
      name                    = "default"
      namespace               = "apps"
      egress                  = [{ hosts = ["./*", "istio-system/*"] }]
      outbound_traffic_policy = { mode = "REGISTRY_ONLY" }
    }
  ]
}

run "plans_cleanly" { command = plan }

run "manifest" {
  command = plan
  assert {
    condition     = kubernetes_manifest.this["default"].manifest.kind == "Sidecar"
    error_message = "kind must be Sidecar."
  }
}

run "rejects_bad_mode" {
  command = plan
  variables {
    sidecars = [{ name = "bad", namespace = "apps", outbound_traffic_policy = { mode = "WHATEVER" } }]
  }
  expect_failures = [var.sidecars]
}
