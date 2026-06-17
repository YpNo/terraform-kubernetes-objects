mock_provider "kubernetes" {}

variables {
  resource_quotas = [
    {
      name      = "compute"
      namespace = "team-a"
      hard      = { "requests.cpu" = "4", "pods" = "20" }
      scopes    = ["NotTerminating"]
    }
  ]
}

run "plans_cleanly" { command = plan }

run "metadata" {
  command = plan
  assert {
    condition     = kubernetes_resource_quota_v1.this["compute"].metadata[0].name == "compute"
    error_message = "name must be compute."
  }
}

run "rejects_bad_scope_operator" {
  command = plan
  variables {
    resource_quotas = [{
      name           = "bad"
      namespace      = "team-a"
      scope_selector = { match_expressions = [{ scope_name = "PriorityClass", operator = "Wrong", values = ["x"] }] }
    }]
  }
  expect_failures = [var.resource_quotas]
}
