mock_provider "kubernetes" {}

variables {
  cron_jobs = [
    {
      name               = "report"
      namespace          = "batch"
      schedule           = "0 2 * * *"
      concurrency_policy = "Forbid"
      pod_labels         = { job = "report" }
      containers         = [{ name = "r", image = "report:1", command = ["/report"] }]
    }
  ]
}

run "plans_cleanly" { command = plan }

run "schedule" {
  command = plan
  assert {
    condition     = kubernetes_cron_job_v1.this["report"].spec[0].schedule == "0 2 * * *"
    error_message = "schedule must match."
  }
}

run "rejects_bad_concurrency" {
  command = plan
  variables {
    cron_jobs = [
      {
        name               = "bad"
        namespace          = "batch"
        schedule           = "* * * * *"
        concurrency_policy = "Nope"
        containers         = [{ name = "c", image = "img" }]
      }
    ]
  }
  expect_failures = [var.cron_jobs]
}
