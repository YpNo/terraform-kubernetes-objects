mock_provider "kubernetes" {}

variables {
  compute_classes = [
    {
      name       = "cost-optimized"
      priorities = [{ machine_family = "e2", spot = true }]
    }
  ]
}

run "plans_cleanly" { command = plan }

run "manifest" {
  command = plan
  assert {
    condition     = kubernetes_manifest.this["cost-optimized"].manifest.apiVersion == "cloud.google.com/v1"
    error_message = "computeclass apiVersion must be cloud.google.com/v1."
  }
}
