mock_provider "kubernetes" {}

variables {
  endpoints = [
    {
      name      = "external-db"
      namespace = "default"
      subsets = [
        {
          address = [{ ip = "10.0.0.4" }, { ip = "10.0.0.5" }]
          port    = [{ name = "https", port = 443, protocol = "TCP" }]
        }
      ]
    }
  ]
}

run "plans_cleanly" { command = plan }

run "metadata" {
  command = plan
  assert {
    condition     = kubernetes_endpoints_v1.this["external-db"].metadata[0].name == "external-db"
    error_message = "name must be external-db."
  }
  assert {
    condition     = kubernetes_endpoints_v1.this["external-db"].metadata[0].namespace == "default"
    error_message = "namespace must be default."
  }
}

run "rejects_bad_protocol" {
  command = plan
  variables {
    endpoints = [{
      name      = "bad"
      namespace = "default"
      subsets   = [{ port = [{ port = 80, protocol = "ICMP" }] }]
    }]
  }
  expect_failures = [var.endpoints]
}
