mock_provider "kubernetes" {}

variables {
  daemon_sets = [
    {
      name                  = "node-exp"
      namespace             = "monitoring"
      selector_match_labels = { app = "node-exp" }
      pod_labels            = { app = "node-exp" }
      host_network          = true
      containers            = [{ name = "exp", image = "prom/node-exporter:v1.8.0" }]
    }
  ]
}

run "plans_cleanly" { command = plan }

run "metadata" {
  command = plan
  assert {
    condition     = kubernetes_daemon_set_v1.this["node-exp"].metadata[0].name == "node-exp"
    error_message = "name must be node-exp."
  }
}
