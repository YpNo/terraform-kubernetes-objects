mock_provider "kubernetes" {}

variables {
  services = [
    {
      name                    = "web"
      namespace               = "default"
      type                    = "LoadBalancer"
      selector                = { app = "web" }
      external_traffic_policy = "Local"
      health_check_node_port  = 32000
      session_affinity        = "ClientIP"

      session_affinity_client_ip_timeout_seconds = 3600
      load_balancer_source_ranges                = ["10.0.0.0/8"]
      ports = [
        { name = "https", port = 443, target_port = 8443, node_port = 30443, app_protocol = "https" }
      ]
    }
  ]
}

run "plans_cleanly" { command = plan }

run "spec_wired" {
  command = plan
  assert {
    condition     = kubernetes_service_v1.this["web"].spec[0].external_traffic_policy == "Local"
    error_message = "external_traffic_policy must be wired"
  }
  assert {
    condition     = kubernetes_service_v1.this["web"].spec[0].session_affinity == "ClientIP"
    error_message = "session_affinity must be wired"
  }
  assert {
    condition     = one(kubernetes_service_v1.this["web"].spec[0].port).node_port == 30443
    error_message = "port.node_port must be wired"
  }
}

run "rejects_bad_type" {
  command = plan
  variables {
    services = [{ name = "bad", namespace = "default", type = "Weird" }]
  }
  expect_failures = [var.services]
}
