mock_provider "kubernetes" {}

variables {
  api_services = [
    {
      name = "v1beta1.metrics.k8s.io"
      spec = {
        group                    = "metrics.k8s.io"
        group_priority_minimum   = 100
        version                  = "v1beta1"
        version_priority         = 100
        insecure_skip_tls_verify = true
        service = {
          name      = "metrics-server"
          namespace = "kube-system"
        }
      }
    }
  ]
}

run "plans_cleanly" { command = plan }

run "metadata" {
  command = plan
  assert {
    condition     = kubernetes_api_service_v1.this["v1beta1.metrics.k8s.io"].metadata[0].name == "v1beta1.metrics.k8s.io"
    error_message = "name must be v1beta1.metrics.k8s.io."
  }
  assert {
    condition     = kubernetes_api_service_v1.this["v1beta1.metrics.k8s.io"].spec[0].group == "metrics.k8s.io"
    error_message = "group must be metrics.k8s.io."
  }
}
