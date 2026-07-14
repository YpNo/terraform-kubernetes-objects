# Peer Authentication Module for Istio/CSM/ASM

Istio `PeerAuthentication` controls mutual TLS (mTLS) for service-to-service traffic, at mesh, namespace, or workload scope, including per-port overrides. This module creates one or more policies from a `list(object)` input via `for_each`. Because these are Istio CRDs rendered through `kubernetes_manifest`, the Istio CRDs must already be installed and a cluster must be reachable at plan time.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.37.1 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.37.1 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [kubernetes_manifest.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_peer_authentications"></a> [peer\_authentications](#input\_peer\_authentications) | A list of Istio PeerAuthentication configurations. | <pre>list(object({<br/>    name        = string           # For mesh-wide, name must be 'default'. For namespace/workload, can be any valid name.<br/>    namespace   = optional(string) # Optional. Omit for mesh-wide policies (name='default').<br/>    labels      = optional(map(string))<br/>    annotations = optional(map(string))<br/><br/>    selector = optional(map(string)) # Labels to select target workloads (pods) for this policy.<br/><br/>    # Default mTLS mode for the workloads/namespace/mesh.<br/>    # "UNSET": Inherit from parent (e.g., from mesh-wide for namespace-wide).<br/>    # "STRICT": All peer communication must be mTLS.<br/>    # "PERMISSIVE": mTLS is optional (both mTLS and plain text allowed).<br/>    # "DISABLE": mTLS is disabled.<br/>    mtls_mode = optional(string)<br/><br/>    # mTLS mode overrides for specific ports. Keys are port numbers as strings.<br/>    # e.g., { "80": "PERMISSIVE", "443": "STRICT" }<br/>    port_level_mtls = optional(map(string), {})<br/>  }))</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage

### with Terraform

```terraform
module "peerauthentication" {
  source = "github.com/YpNo/terraform-kubernetes-objects//modules/istio-objects/peerauthentication?ref=v0.1.0"

  peer_authentications = [
    {
      # Mesh-wide policy (no namespace, name must be 'default')
      name      = "default"
      mtls_mode = "PERMISSIVE" # Allow both mTLS and plain text across the mesh
    },
    {
      # Namespace-wide policy (no selector)
      name      = "default" # Name is 'default' for namespace-wide policy within that namespace
      namespace = "my-secure-namespace"
      mtls_mode = "STRICT" # Enforce mTLS for all services in 'my-secure-namespace'
    },
    {
      # Workload-specific policy (with selector)
      name      = "my-app-mtls"
      namespace = "my-app-namespace"
      selector  = { "app" = "my-service" } # Only applies to pods with app=my-service
      mtls_mode = "STRICT"
      port_level_mtls = {
        "8080" = "PERMISSIVE" # Override for port 8080 on this workload
      }
    }
  ]
}
```

### with Terragrunt

```terraform
...

inputs = { 
  peer_authentications = [
    {
      # Mesh-wide policy (no namespace, name must be 'default')
      name      = "default"
      mtls_mode = "PERMISSIVE" # Allow both mTLS and plain text across the mesh
    },
    {
      # Namespace-wide policy (no selector)
      name      = "default" # Name is 'default' for namespace-wide policy within that namespace
      namespace = "my-secure-namespace"
      mtls_mode = "STRICT" # Enforce mTLS for all services in 'my-secure-namespace'
    },
    {
      # Workload-specific policy (with selector)
      name      = "my-app-mtls"
      namespace = "my-app-namespace"
      selector  = { "app" = "my-service" } # Only applies to pods with app=my-service
      mtls_mode = "STRICT"
      port_level_mtls = {
        "8080" = "PERMISSIVE" # Override for port 8080 on this workload
      }
    }
  ]
}
```
