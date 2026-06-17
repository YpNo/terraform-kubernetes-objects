mock_provider "kubernetes" {}

variables {
  csi_drivers = [
    {
      name = "csi.example.com"
      spec = {
        attach_required        = true
        pod_info_on_mount      = true
        volume_lifecycle_modes = ["Persistent", "Ephemeral"]
      }
    }
  ]
}

run "plans_cleanly" { command = plan }

run "metadata" {
  command = plan
  assert {
    condition     = kubernetes_csi_driver_v1.this["csi.example.com"].metadata[0].name == "csi.example.com"
    error_message = "name must be csi.example.com."
  }
  assert {
    condition     = kubernetes_csi_driver_v1.this["csi.example.com"].spec[0].attach_required == true
    error_message = "attach_required must be true."
  }
}

run "rejects_bad_lifecycle_mode" {
  command = plan
  variables {
    csi_drivers = [{
      name = "bad"
      spec = { attach_required = false, volume_lifecycle_modes = ["Sideways"] }
    }]
  }
  expect_failures = [var.csi_drivers]
}
