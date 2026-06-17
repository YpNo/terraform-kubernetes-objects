mock_provider "kubernetes" {}

variables {
  stateful_sets = [
    {
      name                  = "pg"
      namespace             = "data"
      service_name          = "pg-headless"
      replicas              = 2
      selector_match_labels = { app = "pg" }
      pod_labels            = { app = "pg" }
      containers            = [{ name = "pg", image = "postgres:16" }]
      volume_claim_templates = [
        { name = "data", access_modes = ["ReadWriteOnce"], resources = { requests = { storage = "5Gi" } } }
      ]
    }
  ]
}

run "plans_cleanly" { command = plan }

run "spec_fields" {
  command = plan
  assert {
    condition     = kubernetes_stateful_set_v1.this["pg"].spec[0].service_name == "pg-headless"
    error_message = "service_name must be pg-headless."
  }
  assert {
    condition     = kubernetes_stateful_set_v1.this["pg"].spec[0].replicas == "2"
    error_message = "replicas must be 2."
  }
}
