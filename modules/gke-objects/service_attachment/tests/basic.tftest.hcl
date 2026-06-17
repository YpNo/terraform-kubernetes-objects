mock_provider "kubernetes" {}

variables {
  service_attachments = [
    {
      name                  = "sa"
      namespace             = "apps"
      connection_preference = "ACCEPT_AUTOMATIC"
      nat_subnets           = ["psc-nat-subnet"]
      proxy_protocol        = false
      resource_ref          = { name = "echo-svc" }
    }
  ]
}

run "plans_cleanly" { command = plan }

run "manifest" {
  command = plan
  assert {
    condition     = kubernetes_manifest.this["sa"].manifest.kind == "ServiceAttachment"
    error_message = "kind must be ServiceAttachment."
  }
  assert {
    condition     = kubernetes_manifest.this["sa"].manifest.spec.resourceRef.name == "echo-svc"
    error_message = "resourceRef.name must be echo-svc."
  }
}
