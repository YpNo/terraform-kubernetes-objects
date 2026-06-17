mock_provider "kubernetes" {}

variables {
  authorization_policies = [
    {
      name      = "ext-authz"
      namespace = "apps"
      action    = "CUSTOM"
      provider  = { name = "my-ext-authz" }
      rules     = [{ to = [{ paths = ["/api/*"] }] }]
    }
  ]
}

run "plans_cleanly" { command = plan }

run "manifest" {
  command = plan
  assert {
    condition     = kubernetes_manifest.this["ext-authz"].manifest.spec.action == "CUSTOM"
    error_message = "action must be CUSTOM."
  }
  assert {
    condition     = kubernetes_manifest.this["ext-authz"].manifest.spec.provider.name == "my-ext-authz"
    error_message = "provider.name must match."
  }
}

run "rejects_bad_action" {
  command = plan
  variables {
    authorization_policies = [{ name = "bad", namespace = "apps", action = "MAYBE" }]
  }
  expect_failures = [var.authorization_policies]
}
