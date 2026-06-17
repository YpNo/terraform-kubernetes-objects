mock_provider "kubernetes" {}

variables {
  validating_webhook_configurations = [
    {
      name = "pod-policy.example.com"
      webhooks = [
        {
          name                      = "pod-policy.example.com"
          admission_review_versions = ["v1"]
          side_effects              = "None"
          failure_policy            = "Fail"
          client_config = {
            service = { name = "webhook-svc", namespace = "webhooks", path = "/validate" }
          }
          rules = [{
            api_groups   = [""]
            api_versions = ["v1"]
            operations   = ["CREATE", "UPDATE"]
            resources    = ["pods"]
            scope        = "Namespaced"
          }]
          object_selector = {
            match_labels = { team = "payments" }
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
    condition     = kubernetes_validating_webhook_configuration_v1.this["pod-policy.example.com"].metadata[0].name == "pod-policy.example.com"
    error_message = "name must be pod-policy.example.com."
  }
  assert {
    condition     = kubernetes_validating_webhook_configuration_v1.this["pod-policy.example.com"].webhook[0].name == "pod-policy.example.com"
    error_message = "webhook name must match."
  }
}

run "rejects_bad_failure_policy" {
  command = plan
  variables {
    validating_webhook_configurations = [{
      name = "bad"
      webhooks = [{
        name           = "bad.example.com"
        failure_policy = "Maybe"
        client_config  = { url = "https://example.com/validate" }
      }]
    }]
  }
  expect_failures = [var.validating_webhook_configurations]
}
