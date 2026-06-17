mock_provider "kubernetes" {}

variables {
  gateways = [
    {
      name               = "main"
      namespace          = "apps"
      gateway_class_name = "gke-l7-global"
      listeners = [
        {
          name     = "https"
          protocol = "HTTPS"
          port     = 443
          tls = {
            certificate_refs = [{ name = "web-cert" }]
            options          = { "networking.gke.io/ssl-policy" = "modern" }
          }
        }
      ]
      infrastructure = {
        labels         = { team = "platform" }
        parameters_ref = { group = "networking.gke.io", kind = "GCPGatewayPolicy", name = "gw-policy" }
      }
    }
  ]
}

run "plans_cleanly" { command = plan }

run "manifest" {
  command = plan
  assert {
    condition     = kubernetes_manifest.this["apps-main"].manifest.spec.gatewayClassName == "gke-l7-global"
    error_message = "gatewayClassName must match."
  }
}
