mock_provider "kubernetes" {}

variables {
  ingresses = [
    {
      name                 = "web"
      namespace            = "default"
      ingress_class        = "gce"
      backend_name         = "web-svc"
      backend_port         = 80
      static_ip_address    = "web-ip"
      type                 = "global"
      managed_certificates = ["web-cert"]
      frontend_config      = "web-fc"
      allow_http           = false
      pre_shared_cert      = "web-psc"
      annotations          = { "custom" = "1" }
      rules = [
        {
          host = "web.example.com"
          paths = [
            { path = "/api", path_type = "Prefix", service_name = "api-svc", service_port_number = 8080 }
          ]
        }
      ]
      tls = [
        { hosts = ["web.example.com"], secret_name = "web-tls" }
      ]
    }
  ]
}

run "plans_cleanly" { command = plan }

run "wired" {
  command = plan
  assert {
    condition     = kubernetes_ingress_v1.this["web"].metadata[0].annotations["networking.gke.io/managed-certificates"] == "web-cert"
    error_message = "managed-certificates annotation must be set"
  }
  assert {
    condition     = one(kubernetes_ingress_v1.this["web"].spec[0].rule).host == "web.example.com"
    error_message = "rule host must be wired"
  }
  assert {
    condition     = one(kubernetes_ingress_v1.this["web"].spec[0].tls).secret_name == "web-tls"
    error_message = "tls secret_name must be wired"
  }
}

run "rejects_bad_path_type" {
  command = plan
  variables {
    ingresses = [
      {
        name      = "bad"
        namespace = "default"
        rules     = [{ paths = [{ service_name = "x", path_type = "Nope" }] }]
      }
    ]
  }
  expect_failures = [var.ingresses]
}
