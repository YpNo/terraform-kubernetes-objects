mock_provider "kubernetes" {}

variables {
  http_routes = [
    {
      name        = "web"
      namespace   = "apps"
      parent_refs = [{ name = "main-gateway", port = 443 }]
      hostnames   = ["web.example.com"]
      rules = [
        {
          name = "default"
          filters = [
            { type = "ResponseHeaderModifier", response_header_modifier = { add = [{ name = "X-Served-By", value = "tf" }] } },
            { type = "URLRewrite", url_rewrite = { hostname = "internal.svc" } },
          ]
          timeouts     = { request = "10s", backend_request = "5s" }
          backend_refs = [{ name = "web-svc", port = 8080 }]
        }
      ]
    }
  ]
}

run "plans_cleanly" { command = plan }

run "manifest" {
  command = plan
  assert {
    condition     = kubernetes_manifest.this["apps-web"].manifest.kind == "HTTPRoute"
    error_message = "kind must be HTTPRoute."
  }
}
