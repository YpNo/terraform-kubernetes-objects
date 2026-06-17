mock_provider "kubernetes" {}

variables {
  limit_ranges = [
    {
      name      = "defaults"
      namespace = "team-a"
      limits    = [{ type = "Container", default = { cpu = "200m" }, default_request = { cpu = "100m" } }]
    }
  ]
}

run "plans_cleanly" { command = plan }

run "metadata" {
  command = plan
  assert {
    condition     = kubernetes_limit_range_v1.this["defaults"].metadata[0].name == "defaults"
    error_message = "name must be defaults."
  }
}

run "rejects_bad_limit_type" {
  command = plan
  variables {
    limit_ranges = [{ name = "bad", namespace = "team-a", limits = [{ type = "Galaxy" }] }]
  }
  expect_failures = [var.limit_ranges]
}
