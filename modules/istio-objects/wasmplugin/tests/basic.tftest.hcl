mock_provider "kubernetes" {}

variables {
  wasm_plugins = [
    {
      name      = "openid-connect"
      namespace = "apps"
      url       = "oci://ghcr.io/istio-ecosystem/wasm-extensions/basic_auth:1.12.0"
      phase     = "AUTHN"
      selector  = { match_labels = { app = "httpbin" } }
    }
  ]
}

run "plans_cleanly" { command = plan }

run "manifest" {
  command = plan
  assert {
    condition     = kubernetes_manifest.this["openid-connect"].manifest.kind == "WasmPlugin"
    error_message = "kind must be WasmPlugin."
  }
}

run "rejects_bad_phase" {
  command = plan
  variables {
    wasm_plugins = [{ name = "bad", namespace = "apps", url = "oci://example/x:1", phase = "WHENEVER" }]
  }
  expect_failures = [var.wasm_plugins]
}
