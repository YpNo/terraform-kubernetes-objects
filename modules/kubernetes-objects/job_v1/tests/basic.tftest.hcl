mock_provider "kubernetes" {}

variables {
  jobs = [
    {
      name          = "migrate"
      namespace     = "data"
      backoff_limit = 3
      pod_labels    = { job = "migrate" }
      containers    = [{ name = "m", image = "migrate:1", command = ["/migrate", "up"] }]
    }
  ]
}

run "plans_cleanly" { command = plan }

run "backoff_limit" {
  command = plan
  assert {
    condition     = kubernetes_job_v1.this["migrate"].spec[0].backoff_limit == 3
    error_message = "backoff_limit must be 3."
  }
}

run "rejects_restart_policy_always" {
  command = plan
  variables {
    jobs = [
      {
        name           = "bad"
        namespace      = "data"
        restart_policy = "Always"
        containers     = [{ name = "c", image = "img" }]
      }
    ]
  }
  expect_failures = [var.jobs]
}
