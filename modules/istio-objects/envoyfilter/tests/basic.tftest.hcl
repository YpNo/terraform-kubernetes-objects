mock_provider "kubernetes" {}

variables {
  envoy_filters = [
    {
      name      = "ratelimit"
      namespace = "istio-system"
      config_patches = [
        {
          apply_to = "HTTP_FILTER"
          match    = { context = "GATEWAY" }
          patch    = { operation = "INSERT_BEFORE", value = { name = "envoy.filters.http.ratelimit" } }
        }
      ]
    }
  ]
}

run "plans_cleanly" { command = plan }

run "manifest" {
  command = plan
  assert {
    condition     = kubernetes_manifest.this["ratelimit"].manifest.kind == "EnvoyFilter"
    error_message = "kind must be EnvoyFilter."
  }
}
