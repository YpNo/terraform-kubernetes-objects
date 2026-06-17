# WasmPlugin module

Istio `WasmPlugin` extends the Envoy proxy with custom WebAssembly modules (loaded from a URL or OCI image), inserted at a chosen filter phase to add behavior such as auth, transformation, or telemetry. This module creates one or more plugins from a `list(object)` input via `for_each`. Because these are Istio CRDs rendered through `kubernetes_manifest`, the Istio CRDs must already be installed and a cluster must be reachable at plan time.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.37.1 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 3.2.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [kubernetes_manifest.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_wasm_plugins"></a> [wasm\_plugins](#input\_wasm\_plugins) | A list of Istio WasmPlugin configurations. | <pre>list(object({<br/>    name        = string<br/>    namespace   = string<br/>    labels      = optional(map(string))<br/>    annotations = optional(map(string))<br/><br/>    # Selects the set of pods/VMs on which this WasmPlugin is applied.<br/>    # If omitted, the WasmPlugin applies to all workloads in the namespace.<br/>    selector = optional(object({<br/>      match_labels = map(string)<br/>    }))<br/><br/>    # URL of a Wasm module or OCI container. If no scheme is present, defaults to "oci://".<br/>    url = string<br/><br/>    # SHA256 checksum used to verify the Wasm module or OCI container.<br/>    sha256 = optional(string)<br/><br/>    # Pull behavior for OCI images: "IfNotPresent", "Always", or "UNSPECIFIED_POLICY".<br/>    image_pull_policy = optional(string)<br/><br/>    # Name of a Kubernetes Secret holding OCI registry pull credentials.<br/>    image_pull_secret = optional(string)<br/><br/>    # Plugin identifier used in the Envoy configuration.<br/>    plugin_name = optional(string)<br/><br/>    # Filter chain insertion point: "UNSPECIFIED_PHASE", "AUTHN", "AUTHZ", "STATS".<br/>    phase = optional(string)<br/><br/>    # Ordering within the same phase. Larger numbers run earlier (descending order).<br/>    priority = optional(number)<br/><br/>    # Extension type: "HTTP", "NETWORK", or "UNSPECIFIED_PLUGIN_TYPE".<br/>    type = optional(string)<br/><br/>    # Failure behavior: "FAIL_CLOSE", "FAIL_OPEN", "FAIL_RELOAD".<br/>    fail_strategy = optional(string)<br/><br/>    # Free-form configuration passed to the plugin (rendered as-is into pluginConfig).<br/>    plugin_config = optional(any)<br/><br/>    # Configuration for the Wasm VM.<br/>    vm_config = optional(object({<br/>      env = list(object({<br/>        name = string<br/>        # "INLINE" (value field) or "HOST" (read from host environment).<br/>        value_from = optional(string)<br/>        value      = optional(string)<br/>      }))<br/>    }))<br/>  }))</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with Terragrunt

```terraform
...

inputs = {
  wasm_plugins = [
    {
      name      = "basic-auth"
      namespace = "bookinfo"
      selector  = { match_labels = { app = "productpage" } }
      url       = "oci://ghcr.io/istio-ecosystem/wasm-extensions/basic_auth:1.12.0"
      phase     = "AUTHN"
      plugin_config = {
        basic_auth_rules = [
          {
            prefix    = "/api/v1"
            request_methods = ["GET", "POST"]
            credentials     = ["ok:test"]
          }
        ]
      }
    }
  ]
}
```
