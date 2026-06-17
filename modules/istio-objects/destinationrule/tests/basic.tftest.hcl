mock_provider "kubernetes" {}

variables {
  destination_rules = [
    {
      name              = "web"
      namespace         = "apps"
      host              = "web-svc.apps.svc.cluster.local"
      workload_selector = { app = "web" }
      traffic_policy = {
        load_balancer = {
          simple               = "LEAST_CONN"
          warmup_duration_secs = "30s"
          locality_lb_setting  = { enabled = true }
        }
        outlier_detection = { min_health_percent = 50, consecutive_local_origin_failures = 5 }
      }
    }
  ]
}

run "plans_cleanly" { command = plan }

run "manifest" {
  command = plan
  assert {
    condition     = kubernetes_manifest.this["web"].manifest.spec.workloadSelector.matchLabels.app == "web"
    error_message = "workloadSelector.matchLabels.app must be web."
  }
}
