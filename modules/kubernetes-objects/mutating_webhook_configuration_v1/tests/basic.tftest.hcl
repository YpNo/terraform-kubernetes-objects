mock_provider "kubernetes" {}

variables {
  mutating_webhook_configurations = [
    {
      name = "pod-defaulter.example.com"
      webhooks = [
        {
          name                      = "pod-defaulter.example.com"
          admission_review_versions = ["v1"]
          side_effects              = "None"
          failure_policy            = "Fail"
          reinvocation_policy       = "IfNeeded"
          client_config = {
            service = { name = "webhook-svc", namespace = "webhooks", path = "/mutate" }
          }
          rules = [{
            api_groups   = [""]
            api_versions = ["v1"]
            operations   = ["CREATE"]
            resources    = ["pods"]
            scope        = "Namespaced"
          }]
          namespace_selector = {
            match_expressions = [{ key = "env", operator = "In", values = ["prod"] }]
          }
        }
      ]
    }
  ]
}

run "plans_cleanly" { command = plan }

run "metadata" {
  command = plan
  assert {
    condition     = kubernetes_mutating_webhook_configuration_v1.this["pod-defaulter.example.com"].metadata[0].name == "pod-defaulter.example.com"
    error_message = "name must be pod-defaulter.example.com."
  }
  assert {
    condition     = kubernetes_mutating_webhook_configuration_v1.this["pod-defaulter.example.com"].webhook[0].name == "pod-defaulter.example.com"
    error_message = "webhook name must match."
  }
}

run "rejects_bad_failure_policy" {
  command = plan
  variables {
    mutating_webhook_configurations = [{
      name = "bad"
      webhooks = [{
        name           = "bad.example.com"
        failure_policy = "Maybe"
        client_config  = { url = "https://example.com/mutate" }
      }]
    }]
  }
  expect_failures = [var.mutating_webhook_configurations]
}

run "rejects_bad_reinvocation_policy" {
  command = plan
  variables {
    mutating_webhook_configurations = [{
      name = "bad"
      webhooks = [{
        name                = "bad.example.com"
        reinvocation_policy = "Always"
        client_config       = { url = "https://example.com/mutate" }
      }]
    }]
  }
  expect_failures = [var.mutating_webhook_configurations]
}
