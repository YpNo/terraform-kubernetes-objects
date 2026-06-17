mock_provider "kubernetes" {}

variables {
  workload_groups = [
    {
      name      = "reviews"
      namespace = "apps"
      template = {
        ports           = { http = 8080 }
        service_account = "reviews-sa"
        network         = "vm-network"
      }
      probe = {
        period_seconds = 10
        http_get = {
          path = "/healthz"
          port = 8080
        }
      }
    }
  ]
}

run "plans_cleanly" { command = plan }

run "manifest" {
  command = plan
  assert {
    condition     = kubernetes_manifest.this["reviews"].manifest.kind == "WorkloadGroup"
    error_message = "kind must be WorkloadGroup."
  }
}
