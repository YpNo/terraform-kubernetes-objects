mock_provider "kubernetes" {}

variables {
  network_policies = [
    {
      name         = "allow-fe"
      namespace    = "default"
      pod_selector = { match_labels = { app = "backend" } }
      policy_types = ["Ingress", "Egress"]
      ingress = [{
        ports = [{ port = "8080", protocol = "TCP" }]
        from  = [{ pod_selector = { match_labels = { app = "frontend" } } }, { ip_block = { cidr = "10.0.0.0/8", except = ["10.0.0.0/24"] } }]
      }]
      egress = [{ to = [{ namespace_selector = {} }] }]
    }
  ]
}

run "plans_cleanly" { command = plan }

run "metadata" {
  command = plan
  assert {
    condition     = kubernetes_network_policy_v1.this["allow-fe"].metadata[0].name == "allow-fe"
    error_message = "name must be allow-fe."
  }
}

run "rejects_bad_policy_type" {
  command = plan
  variables {
    network_policies = [{ name = "bad", namespace = "default", policy_types = ["Sideways"] }]
  }
  expect_failures = [var.network_policies]
}
