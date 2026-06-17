mock_provider "kubernetes" {}

variables {
  workload_entries = [
    {
      name            = "vm-1"
      namespace       = "apps"
      address         = "10.0.0.1"
      ports           = { http = 8080 }
      service_account = "my-sa"
    }
  ]
}

run "plans_cleanly" { command = plan }

run "manifest" {
  command = plan
  assert {
    condition     = kubernetes_manifest.this["vm-1"].manifest.kind == "WorkloadEntry"
    error_message = "kind must be WorkloadEntry."
  }
}
