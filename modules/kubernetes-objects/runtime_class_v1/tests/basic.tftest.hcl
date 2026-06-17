mock_provider "kubernetes" {}

variables {
  runtime_classes = [
    {
      name    = "gvisor"
      handler = "runsc"
    }
  ]
}

run "plans_cleanly" { command = plan }

run "metadata" {
  command = plan
  assert {
    condition     = kubernetes_runtime_class_v1.this["gvisor"].metadata[0].name == "gvisor"
    error_message = "name must be gvisor."
  }
  assert {
    condition     = kubernetes_runtime_class_v1.this["gvisor"].handler == "runsc"
    error_message = "handler must be runsc."
  }
}
