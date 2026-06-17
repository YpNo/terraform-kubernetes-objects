mock_provider "kubernetes" {}

variables {
  gcp_traffic_distribution_policies = [
    {
      name      = "tdp"
      namespace = "apps"
      default = {
        service_lb_algorithm = "WATERFALL_BY_REGION"
        failover_config      = { failover_health_threshold = 70 }
      }
      target_refs = [{ name = "echo-svc" }]
    }
  ]
}

run "plans_cleanly" { command = plan }

run "manifest" {
  command = plan
  assert {
    condition     = kubernetes_manifest.this["tdp"].manifest.kind == "GCPTrafficDistributionPolicy"
    error_message = "kind must be GCPTrafficDistributionPolicy."
  }
  assert {
    condition     = kubernetes_manifest.this["tdp"].manifest.spec.targetRefs[0].name == "echo-svc"
    error_message = "targetRefs[0].name must be echo-svc."
  }
}
