mock_provider "kubernetes" {}

variables {
  virtual_services = [
    {
      name      = "web"
      namespace = "apps"
      hosts     = ["web.example.com"]
      gateways  = ["mesh"]
      http = [
        {
          route   = [{ destination = { host = "web-svc" } }]
          headers = { request = { set = { "X-Env" = "prod" }, remove = ["X-Debug"] } }
        },
        {
          direct_response = { status = 503, body = { string = "maintenance" } }
        }
      ]
    }
  ]
}

run "plans_cleanly" { command = plan }

run "manifest" {
  command = plan
  assert {
    condition     = kubernetes_manifest.this["web"].manifest.kind == "VirtualService"
    error_message = "kind must be VirtualService."
  }
}
