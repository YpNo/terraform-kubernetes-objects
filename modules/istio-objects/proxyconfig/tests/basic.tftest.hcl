mock_provider "kubernetes" {}

variables {
  proxy_configs = [
    {
      name                  = "global"
      namespace             = "apps"
      concurrency           = 2
      environment_variables = { ISTIO_META_DNS_CAPTURE = "true" }
    }
  ]
}

run "plans_cleanly" { command = plan }

run "manifest" {
  command = plan
  assert {
    condition     = kubernetes_manifest.this["global"].manifest.kind == "ProxyConfig"
    error_message = "kind must be ProxyConfig."
  }
}

run "rejects_bad_image_type" {
  command = plan
  variables {
    proxy_configs = [{ name = "bad", namespace = "apps", image = { image_type = "supersize" } }]
  }
  expect_failures = [var.proxy_configs]
}
